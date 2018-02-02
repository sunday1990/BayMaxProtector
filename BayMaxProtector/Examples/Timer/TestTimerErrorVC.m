//
//  TestTimerErrorVC.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestTimerErrorVC.h"

@interface TestTimerErrorVC ()
{
    NSTimer *_timer;
}
@end

@implementation TestTimerErrorVC
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [BayMaxProtector closeProtectionsOn:BayMaxProtectionTypeTimer];
    //_timer未移除
    
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [BayMaxProtector hideDebugView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)timerEvent{
    NSLog(@"timer");
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========

#pragma mark ======== Private Methods ========

#pragma mark ======== Setters && Getters ========

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


