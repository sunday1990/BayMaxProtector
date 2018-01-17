//
//  BayMaxTimerSubTarget.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/16.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BayMaxTimerSubTarget : NSObject{
    @package
    NSTimeInterval _ti;
    __weak id _aTarget;
    SEL _aSelector;
    __weak id _userInfo;
    BOOL _yesOrNo;
}

+ (nonnull instancetype)sharedBayMaxTimerSubTarget;

@end
