//
//  BayMaxCatchError.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/18.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const BMPErrorCallStackSymbols;

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

/*Containers错误原因描述*/
/*数组越界*/
FOUNDATION_EXPORT NSString *const BMPErrorArray_Beyond;
/*数组insert nil*/
FOUNDATION_EXPORT NSString *const BMPErrorArray_NilObject;
/*字典Nil key*/
FOUNDATION_EXPORT NSString *const BMPErrorDictionary_NilKey;
/*字典 undefinedKey*/
FOUNDATION_EXPORT NSString *const BMPErrorDictionary_UndefinedKey;
/*String out of bounds*/
FOUNDATION_EXPORT NSString *const BMPErrorString_Beyond;

typedef NS_ENUM(NSInteger, BayMaxErrorType) {
    /*UnrecognizedSelector异常*/
    BayMaxErrorTypeUnrecognizedSelector = 1,
    /*KVO异常*/
    BayMaxErrorTypeKVO,
    /*Notification异常*/
    BayMaxErrorTypeNotification,
    /*Timer异常*/
    BayMaxErrorTypeTimer,
    /*Containers*/
    BayMaxErrorTypeContainers
};

@interface BayMaxCatchError : NSObject

/**
 错误类型
 */
@property (nonatomic, assign) BayMaxErrorType errorType;
/**
 错误信息字典，通过相对应的key获取
 */
@property (nonatomic, copy) NSDictionary *errorInfos;
/**
 错误标题
 */
@property (nonatomic, copy) NSString *errorName;
/**
 错误堆栈
 */
@property (nonatomic, copy) NSArray *errorCallStackSymbols;

/**
 初始化方法

 @param errorType 错误类型
 @param errorInfos 错误信息字典
 @return 错误实例
 */
+ (instancetype)BMPErrorWithType:(BayMaxErrorType)errorType infos:(NSDictionary *)errorInfos;

@end
