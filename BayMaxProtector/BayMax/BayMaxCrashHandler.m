//
//  BayMaxCrashHandler.m
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxCrashHandler.h"

@implementation BayMaxCrashHandler

static BayMaxCrashHandler *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)sharedBayMaxCrashHandler{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (void)forwardingCrashMethodInfos:(NSDictionary *_Nullable)infos{
    NSLog(@"details:%@",infos);
    /*
     1、实现页面降级
     2、实现错误信息上传服务器
     */
#ifdef DEBUG
    
#else
    
#endif
}

@end
