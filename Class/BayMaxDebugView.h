//
//  BayMaxDebugView.h
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.

//功能：
//1、当有错误信息的时候，加红展示，并记录错误信息的数目，有多少错误信息就展示多少。
//2、当点击后展示所有的错误信息
//3、当收起后，计数清零，错误信息清空。
//4、可以跟随手指移动


#import <UIKit/UIKit.h>

@interface BayMaxDebugView : UIView
/**
 获取DebugView单例

 @return DebugView
 */
+ (instancetype _Nonnull )sharedDebugView;

- (void)addErrorInfo:(NSDictionary *_Nonnull)errorInfo;

@end
