//
//  BayMaxKVODelegate.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/12.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxKVODelegate.h"
#include <CommonCrypto/CommonCrypto.h>
#include <zlib.h>

static NSLock *_bmp_kvoLock;

static inline NSString *BMP_md5StringOfObject(NSObject *object){
    NSString *string = [NSString stringWithFormat:@"%p",object];
    const char *str = string.UTF8String;
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", buffer[i]];
    }
    return output;
}

@interface KVOInfo: NSObject

@end

@implementation KVOInfo
{
    @package
    void *_context;
    NSKeyValueObservingOptions _options;
    __weak NSObject *_observer;
    NSString *_keyPath;
    NSString *_md5Str;
}
@end

@implementation BayMaxKVODelegate

{
    @private
    NSMutableDictionary<NSString*, NSMutableArray<KVOInfo *> *> *_keyPathMaps;
}

- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        _keyPathMaps = [NSMutableDictionary dictionary];
        _bmp_kvoLock = [[NSLock alloc]init];
    }
    return self;
}

- (BOOL)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context{
    BOOL success;
    //先判断有没有重复添加,有的话报错，没有的话，添加到数组中
    [_bmp_kvoLock lock];
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    __block BOOL isExist = NO;
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj->_observer == observer) {
            isExist = YES;
        }
    }];
    if (isExist) {//已经存在了
        success = NO;
    }else{
        KVOInfo *info = [[KVOInfo alloc]init];
        info->_observer = observer;
        info->_md5Str = BMP_md5StringOfObject(observer);
        info->_keyPath = keyPath;
        info->_options = options;
        info->_context = context;
        [kvoInfos addObject:info];
        [self setKVOInfos:kvoInfos ForKeypath:keyPath];
        success = YES;
    }
    [_bmp_kvoLock unlock];
    return success;
}

- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context
                             success:(void(^)(void))success
                             failure:(void(^)(NSError *error))failure{
    [_bmp_kvoLock lock];
    //先判断有没有重复添加,有的话报错，没有的话，添加到数组中
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    __block BOOL isExist = NO;
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj->_observer == observer) {
            isExist = YES;
        }
    }];
    if (isExist) {//已经存在了
        if (failure) {
            NSInteger code = -1234;
            NSString *msg = [NSString stringWithFormat:@"\n observer重复添加:\n observer:%@\n keypath:%@ \n",observer,keyPath];
            NSError * error = [NSError errorWithDomain:@"com.BayMax.BayMaxKVODelegate" code:code userInfo:@{@"NSLocalizedDescriptionKey":msg}];            
            failure(error);
        }
    }else{
        KVOInfo *info = [[KVOInfo alloc]init];
        info->_observer = observer;
        info->_md5Str = BMP_md5StringOfObject(observer);
        info->_keyPath = keyPath;
        info->_options = options;
        info->_context = context;
        [kvoInfos addObject:info];
        [self setKVOInfos:kvoInfos ForKeypath:keyPath];
        if (success) {
            success();
        }
    }
    [_bmp_kvoLock unlock];
}

- (BOOL)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath{
    [_bmp_kvoLock lock];
    BOOL success;
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    __block BOOL isExist = NO;
    __block KVOInfo *kvoInfo;
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj->_md5Str isEqualToString:BMP_md5StringOfObject(observer)]) {
            isExist = YES;
            kvoInfo = obj;
        }
    }];
    if (kvoInfo) {
        [kvoInfos removeObject:kvoInfo];
        if (kvoInfos.count == 0) {//说明该keypath没有observer观察，可以移除该键
            [_keyPathMaps removeObjectForKey:keyPath];
        }
    }
    success = isExist;
    [_bmp_kvoLock unlock];
    return success;
}

#pragma mark 获取keypath对应的所有观察者
- (NSMutableArray *)getKVOInfosForKeypath:(NSString *)keypath{
    if ([_keyPathMaps.allKeys containsObject:keypath]) {
        return [_keyPathMaps objectForKey:keypath];
    }else{
        return [NSMutableArray array];
    }
}

#pragma mark  设置keypath对应的观察者数组
- (void)setKVOInfos:(NSMutableArray *)kvoInfos ForKeypath:(NSString *)keypath{
    if (![_keyPathMaps.allKeys containsObject:keypath]) {
        if (keypath) {
            _keyPathMaps[keypath] = kvoInfos;
        }
    }
}

#pragma mark 实际观察者执行相对应的监听方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj->_keyPath isEqualToString:keyPath]) {
            NSObject *observer = obj->_observer;
            if (observer) {
                [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            }
        }
    }];
}

#pragma mark 获取所有被观察的keypaths
- (NSArray *)getAllKeypaths{
    NSArray <NSString *>*keyPaths = _keyPathMaps.allKeys;
    return keyPaths;
}

@end
