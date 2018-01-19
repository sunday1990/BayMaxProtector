//
//  BayMaxCatchError.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/18.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

/*发生错误的类或者对象*/
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Receiver;
/*发生错误的方法*/
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Func;
/*发生错误的视图控制器*/
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_VC;
/*发生错误的原因简述*/
FOUNDATION_EXPORT NSString *const BMPErrorUnrecognizedSel_Reason;


/*发生KVO重复监听错误的observer*/
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Observer;
/*发生KVO重复监听错误的keypath*/
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Keypath;
/*被重复观察的target*/
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Target;
/*错误原因简述*/
FOUNDATION_EXPORT NSString *const BMPErrorKVO_Reason;

/*timer绑定的target*/
FOUNDATION_EXPORT NSString *const BMPErrorTimer_Target;
/*timer错误原因简述*/
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