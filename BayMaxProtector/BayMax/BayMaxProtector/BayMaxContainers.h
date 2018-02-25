//
//  BayMaxContainers.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/14.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

//针对NSArray/NSMutableArray/NSDictionary/NSMutableDictionary/NSString/NSMutableString进行崩溃保护

#import <Foundation/Foundation.h>

@class BayMaxCatchError;
@interface BayMaxContainers : NSObject

/**
 swizzle容器类方法

 @param errorHandler 错误回调
 */
+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler;

@end
