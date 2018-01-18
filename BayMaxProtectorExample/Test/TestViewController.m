//
//  TestNotificationViewController.m
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
{
    NSTimer *_timer;
}
@end

@implementation TestViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];

    //1、unrecognizedSelector
    NSNull *null = [NSNull null];
    [self performSelector:NSSelectorFromString(@"abc")];
    //2、timer未invalidate
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(click) userInfo:nil repeats:YES];
    
    //3、observer重复添加、
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    
    //4、NSNotification未移除
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notify_test) name:UITextFieldTextDidChangeNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)click{
    NSLog(@"timer_test");
}

- (void)notify_test{
    
    NSLog(@"notification_test");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    //observer重复移除
    [self removeObserver:self forKeyPath:@"progress"];
    [self removeObserver:self forKeyPath:@"progressd"];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


