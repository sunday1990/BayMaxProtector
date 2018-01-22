//
//  Test2ViewController.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "Test2ViewController.h"
#import "TestViewController.h"
#import "TestView.h"

@interface Test2ViewController ()
{
    TestView *view;
}
@end

@implementation Test2ViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [UIImageView performSelector:NSSelectorFromString(@"abcd")];
    self.view.backgroundColor = [UIColor grayColor];
    view = [[TestView alloc]initWithFrame:CGRectMake(200, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    /*测试viewdidload中方法出错*/
    [self test];
    
    UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 12, 40, 20);
    [dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
    [dismissBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dismissBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [dismissBtn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissBtn];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)test{
    [self test1];
    
}

- (void)test1{
    [self test2];

}

- (void)test2{
    [self test3];
}

- (void)test3{
    /*实例方法*/
    [[NSNull null] performSelector:NSSelectorFromString(@"abc")];
    /*类方法*/
//    [UIImageView performSelector:NSSelectorFromString(@"abckd")];
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

#pragma mark ======== Private Methods ========

#pragma mark ======== Setters && Getters ========
- (void)dealloc{
    NSLog(@"dealloc vc2");    
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


