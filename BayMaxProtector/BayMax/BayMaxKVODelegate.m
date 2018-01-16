//
//  BayMaxKVODelegate.m
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/12.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxKVODelegate.h"

@interface KVOInfo: NSObject

@end

@implementation KVOInfo
{
    @package
    void *_context;
    NSKeyValueObservingOptions _options;
    __weak NSObject *_observer;
    __weak NSString *_keyPath;
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
    }
    return self;
}

- (BOOL)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context{
    BOOL success;
    //先判断有没有重复添加,有的话报错，没有的话，添加到数组中
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    __block BOOL isExist = NO;
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj->_observer == observer) {
            isExist = YES;
        }
    }];
    if (isExist) {//已经存在了
//        NSLog(@"observer重复添加->observer:%@\n keypath:%@",observer,keyPath);
        success = NO;
    }else{
        KVOInfo *info = [[KVOInfo alloc]init];
        info->_observer = observer;
        info->_keyPath = keyPath;
        info->_options = options;
        info->_context = context;
        [kvoInfos addObject:info];
        [self setKVOInfos:kvoInfos ForKeypath:keyPath];
        success = YES;
    }
    return success;
}

- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context
                             success:(void(^)(void))success
                             failure:(void(^)(NSError *error))failure{
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
        info->_keyPath = keyPath;
        info->_options = options;
        info->_context = context;
        [kvoInfos addObject:info];
        [self setKVOInfos:kvoInfos ForKeypath:keyPath];
        if (success) {
            success();
        }
    }
}

- (BOOL)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath{
    BOOL success;
    NSMutableArray <KVOInfo *> *kvoInfos = [self getKVOInfosForKeypath:keyPath];
    __block BOOL isExist = NO;
    __block KVOInfo *kvoInfo;
    [kvoInfos enumerateObjectsUsingBlock:^(KVOInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj->_observer == observer) {
            isExist = YES;
            kvoInfo = obj;
        }
    }];
    if (kvoInfo) {
        [kvoInfos removeObject:kvoInfo];
    }
    if (isExist) {
    
    }else{
        
    }
    success = isExist;
    return success;
}

- (NSMutableArray *)getKVOInfosForKeypath:(NSString *)keypath{
    if ([_keyPathMaps.allKeys containsObject:keypath]) {
        return [_keyPathMaps objectForKey:keypath];
    }else{
        return [NSMutableArray array];
    }
}

- (void)setKVOInfos:(NSMutableArray *)kvoInfos ForKeypath:(NSString *)keypath{
    if (![_keyPathMaps.allKeys containsObject:keypath]) {
        if (keypath) {
            _keyPathMaps[keypath] = kvoInfos;
        }
    }
}

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

- (NSArray *)getAllKeypaths{
    NSArray <NSString *>*keyPaths = _keyPathMaps.allKeys;
    return keyPaths;
}

@end
