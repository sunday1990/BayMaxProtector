//
//  BayMaxCatchError.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/18.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Cls;
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Func;
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_VC;
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Reason;

FOUNDATION_EXPORT NSString *const BMPErrorKVO_Observer;
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Keypath;
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Target;
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Reason;

FOUNDATION_EXPORT NSString *const BMPErrorTimer_Target;
FOUNDATION_EXPORT NSString *const BMPErrorTimer_Reason;

typedef NS_ENUM(NSInteger, BayMaxErrorType) {
    /*UnrecognizedSelector异常*/
    BayMaxErrorTypeUnrecognizedSelector = 1,
    /*KVO异常*/
    BayMaxErrorTypeKVO,
    /*Notification异常*/
    BayMaxErrorTypeNotification,
    /*Timer异常*/
    BayMaxErrorTypeTimer
};

@interface BayMaxCatchError : NSObject

@property (nonatomic, assign) BayMaxErrorType errorType;

@property (nonatomic, copy) NSDictionary *errorInfos;

+ (instancetype)BMPErrorWithType:(BayMaxErrorType)errorType infos:(NSDictionary *)errorInfos;

@end
