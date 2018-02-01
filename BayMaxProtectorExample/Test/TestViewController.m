//
//  TestNotificationViewController.m
//  AvoidCrashTest
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestViewController.h"
#import "Test2ViewController.h"

@interface TestViewController ()
{
    NSTimer *_timer;
}
@property (nonatomic, copy) NSString *progress;
@property (nonatomic, copy) NSString *progress1;

@end

@implementation TestViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor orangeColor];
    /*0、模仿网络错误*/
//    [self imitateNetWorkError];
  
//    1、unrecognizedSelector
//    [self performSelector:NSSelectorFromString(@"abc")];
    
//    2、timer未invalidate
//    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(click) userInfo:nil repeats:YES];
    
    //3、observer重复添加、
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
//    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    //同一个observer，观察不同的keypath
    [self addObserver:self forKeyPath:@"progress1" options:NSKeyValueObservingOptionNew context:nil];
    
    UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 12, 40, 20);
    [dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
    [dismissBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    dismissBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissBtn];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*模仿网络错误*/
- (void)imitateNetWorkError{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSNull *null = [NSNull null];
        [null performSelector:NSSelectorFromString(@"abc")];
    });
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
    NSLog(@"dealloc testvc");
    //observer重复移除
//    [self removeObserver:self forKeyPath:@"progress"];
//    [self removeObserver:self forKeyPath:@"progressd"];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    Test2ViewController *test2VC = [[Test2ViewController alloc]init];
    test2VC.ios_param0 = @"1000";
    test2VC.ios_param1 = @"params";
    [self presentViewController:test2VC animated:YES completion:nil];
}

- (void)abc{
    [[NSNull null]performSelector:NSSelectorFromString(@"dhak")];
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


