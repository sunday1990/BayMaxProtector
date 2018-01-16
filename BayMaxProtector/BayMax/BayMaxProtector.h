//
//  BayMaxProtector.h
//  SpaceHome
//
//  Created by ccSunday on 2017/3/23.
//
//

#import <Foundation/Foundation.h>

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

@end

