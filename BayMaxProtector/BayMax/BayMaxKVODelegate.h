//
//  BayMaxKVODelegate.h
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/12.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BayMaxKVODelegate : NSObject

- (void)addKVOInfoToMapsWithObserver:(NSObject *)observer
                      forKeyPath:(NSString *)keyPath
                         options:(NSKeyValueObservingOptions)options
                         context:(void *)context
                         success:(void(^)(void))success
                         failure:(void(^)(NSError *error))failure;

- (BOOL)addKVOInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(void *)context;

- (BOOL)removeKVOInfoInMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath;

- (NSArray *)getAllKeypaths;
@end


