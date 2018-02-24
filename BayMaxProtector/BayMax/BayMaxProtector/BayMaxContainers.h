//
//  BayMaxContainers.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/14.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

//针对NSArray/NSMutableArray/NSDictionary/NSMutableDictionary/NSString/NSMutableString进行崩溃保护
//Thanks to AvoidCrash:https://github.com/chenfanfang/AvoidCrash

#import <Foundation/Foundation.h>

@class BayMaxCatchError;
@interface BayMaxContainers : NSObject
+ (void)BMPExchangeContainersMethodsWithCatchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler;

@end
