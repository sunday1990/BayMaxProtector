//
//  BayMaxCrashHandler.h
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BayMaxCrashHandler : NSObject

+ (nonnull instancetype)sharedBayMaxCrashHandler;

- (void)forwardingCrashMethodInfos:(NSDictionary *_Nullable)infos;

@end
