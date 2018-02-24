//
//  BayMaxTimerSubTarget.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/16.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayMaxCFunctions.h"

@interface BayMaxTimerSubTarget : NSObject

/**
 BayMaxTimerSubTarget初始化方法

 @param ti ti
 @param aTarget aTarget 
 @param aSelector aSelector
 @param userInfo userInfo
 @param yesOrNo yesOrNo
 @param errorHandler 错误回调
 @return subTarget实例
 */
+ (instancetype)targetWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo catchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler;

@end
