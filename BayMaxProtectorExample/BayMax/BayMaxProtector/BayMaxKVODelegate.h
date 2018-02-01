//
//  BayMaxKVODelegate.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/12.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BayMaxKVODelegate : NSObject

/**
 将添加kvo时的相关信息加入到关系maps中，对应原有的添加观察者
 带成功和失败的回调

 @param observer observer观察者
 @param keyPath keyPath
 @param options options
 @param context context
 @param success success 成功的回调
 @param failure failure 失败的回调
 */
- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                      forKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context
                         success:(void(^)(void))success
                         failure:(void(^)(NSError *error))failure;

/**
将添加kvo时的相关信息加入到关系maps中，对应原有的添加观察者
  不带成功和失败的回调
 @param observer 实际观察者
 @param keyPath keyPath
 @param options options
 @param context context
 @return return 是否添加成功
 */
- (BOOL)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context;

/**
 从关系maps中移除观察者 对应原有的移除观察者操作

 @param observer 实际观察者
 @param keyPath keypath
 @return 是否移除成功
 如果重复移除，会返回NO
 */
- (BOOL)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath;

- (NSArray *)getAllKeypaths;
@end


