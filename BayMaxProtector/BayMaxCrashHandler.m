//
//  BayMaxCrashHandler.m
//  BayMaxProtector
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
    NSLog(@"BMPError_UnrecgonizedSelector_Details:\n%@",infos);
    /*
     1、实现页面降级:需要知道出现问题的页面，
     2、实现错误信息上传服务器
     */
    //获取对应的类，该类的参数、
#ifdef DEBUG
#else    
#endif
}

@end
