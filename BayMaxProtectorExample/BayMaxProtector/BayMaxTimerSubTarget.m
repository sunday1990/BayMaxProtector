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

typedef void(^BMPErrorHandler)(BayMaxCatchError *_Nullable error);

BMPErrorHandler _Nullable _timerErrorHandler;

@implementation BayMaxTimerSubTarget{
    @package
    NSTimeInterval _ti;
    __weak id _aTarget;
    SEL _aSelector;
    __weak id _userInfo;
    BOOL _yesOrNo;
    NSString *_targetClassName;
}

+ (instancetype)targetWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo catchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler{
    return [[self alloc]initWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo catchErrorHandler:errorHandler];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo catchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler{
    if (self = [super init]) {
        _ti = ti;
        _aTarget = aTarget;
        _aSelector = aSelector;
        _userInfo = userInfo;
        _yesOrNo = yesOrNo;
        _targetClassName = NSStringFromClass([aTarget class]);
        _timerErrorHandler = errorHandler;
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
        NSString *errorDes = [NSString stringWithFormat:@"Timer %@ did not invalidate in Class<%@>",timer,_targetClassName];
        BayMaxCatchError *bmpError = [BayMaxCatchError BMPErrorWithType:BayMaxErrorTypeTimer infos:@{
                                                                                                     BMPErrorTimer_Target:_targetClassName == nil?@"":_targetClassName,
                                                                                                     BMPErrorTimer_Reason:errorDes
                                                                                                   }];
        if (_timerErrorHandler) {
            _timerErrorHandler(bmpError);
        }
        [timer invalidate];
        timer = nil;
    }
}

@end
