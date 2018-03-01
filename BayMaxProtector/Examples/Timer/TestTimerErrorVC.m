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
    //_timer未移除    
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, WIDTH-20, 200)];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor darkTextColor];
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"针对NSTimer的两个类方法进行保护，一个是+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo，另一个是scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo,退出页面时，会自动invalid计时器";
    [self.view addSubview:tipLabel];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
//    [_timer invalidate];
//    _timer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ======== NetWork ========

#pragma mark ======== System Delegate ========

#pragma mark ======== Custom Delegate ========

#pragma mark ======== Notifications && Observers ========

#pragma mark ======== Event Response ========
- (void)timerEvent{
    NSLog(@"timer");
}

- (void)time1Event{
    NSLog(@"timer1");
}

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


