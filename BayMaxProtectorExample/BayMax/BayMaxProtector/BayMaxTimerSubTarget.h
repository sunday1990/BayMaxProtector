//
//  BayMaxTimerSubTarget.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/16.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BayMaxCatchError.h"

@interface BayMaxTimerSubTarget : NSObject

+ (instancetype)targetWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo catchErrorHandler:(void(^)(BayMaxCatchError * error))errorHandler;

@end
