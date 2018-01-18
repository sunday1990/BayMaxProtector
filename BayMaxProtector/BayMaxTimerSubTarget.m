//
//  BayMaxTimerSubTarget.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/16.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxTimerSubTarget.h"
#import <objc/runtime.h>

#define BMPSuppressPerformSelectorLeakWarning(Stuff)\
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

@implementation BayMaxTimerSubTarget{
    @package
    NSTimeInterval _ti;
    __weak id _aTarget;
    SEL _aSelector;
    __weak id _userInfo;
    BOOL _yesOrNo;
    NSString *_targetClassName;
}

+ (instancetype)targetWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    return [[self alloc]initWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo{
    if (self = [super init]) {
        _ti = ti;
        _aTarget = aTarget;
        _aSelector = aSelector;
        _userInfo = userInfo;
        _yesOrNo = yesOrNo;
        _targetClassName = NSStringFromClass([aTarget class]);
    }
    return self;
}

- (void)fireProxyTimer:(NSTimer *)timer{
    if (_aTarget) {
        if ([_aTarget respondsToSelector:_aSelector]) {
            BMPSuppressPerformSelectorLeakWarning(
               [_aTarget performSelector:_aSelector];
            );
        }
    }else{
        //报错
        NSLog(@"BMPError_Timer_Details:timer did not invalidate in Class<%@>",_targetClassName);
        [timer invalidate];
        timer = nil;
    }
}

@end
