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
    NSTimer *timer;
}
@end

@implementation TestViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSNull *null = [NSNull null];
    [null performSelector:NSSelectorFromString(@"abc")];
    
    self.view.backgroundColor = [UIColor orangeColor];
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(click) userInfo:nil repeats:YES];
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self performSelector:NSSelectorFromString(@"abc")];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)click{
    NSLog(@"click");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"notification dealloc");
//    [self removeObserver:self forKeyPath:@"progress"];
//    [self removeObserver:self forKeyPath:@"progressd"];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissViewControllerAnimated:YES completion:nil];
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


