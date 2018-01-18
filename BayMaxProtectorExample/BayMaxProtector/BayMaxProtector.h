//
//  BayMaxProtector.h
//  BayMaxProtector
//
//  Created by ccSunday on 2017/3/23.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayMaxCatchError.h"

typedef NS_ENUM(NSInteger, BayMaxProtectionType) {
    /*开启全部保护*/
    BayMaxProtectionTypeAll = 0,
    /*UnrecognizedSelector保护*/
    BayMaxProtectionTypeUnrecognizedSelector = 1<<0,
    /*KVO保护*/
    BayMaxProtectionTypeKVO = 1<<1,
    /*Notification*/
    BayMaxProtectionTypeNotification = 1<<2,
    /*Timer保护*/
    BayMaxProtectionTypeTimer = 1<<3
};

@interface BayMaxProtector : NSObject

/**
 开启崩溃保护（支持或运算）

 @param protectionType protectionType description
 */
+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType;

/**
开启崩溃保护（支持或运算并且带错误回调）

 @param protectionType 保护类型
 @param errorHandler 错误回调
 */
+ (void)openProtectionsOn:(BayMaxProtectionType)protectionType catchErrorHandler:(void(^_Nullable)(BayMaxCatchError * _Nullable error))errorHandler;

/**
 设置白名单
 作用：忽略对具有以下指定前缀的框架的保护（多是系统框架），原因一是减少不必要的操作，二是避免kvo异常发生错误
 已默认忽略带有[@"_",
             @"__",
             @"NS",
             @"CA",
             @"UI",
             @"AV",
             @"_UI",
             @"_NS",
             @"AV"
             ]前缀的框架
 
使用：如果想忽略带有CS前缀的类，那么ignorePrefixes为@[@"CS"]即可。

注意：设置对unrecognizedSelctor错误不起作用。
 
 @param ignorePrefixes 要忽略的框架的前缀
 */
+ (void)ignoreProtectionsOnFrameworksWithPrefix:(NSArray *_Nonnull)ignorePrefixes;

@end

