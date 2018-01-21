//
//  ViewController.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "Test2ViewController.h"

#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.view.backgroundColor = [UIColor greenColor];
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    TestViewController *testVC = [[TestViewController alloc]init];
//    testVC.ios_ID = @"10000";
//    testVC.ios_typeID = @"type00";
//    [self presentViewController:testVC animated:YES completion:nil];

    Test2ViewController *test2VC = [[Test2ViewController alloc]init];
//    test2VC.ios_param0 = @"1000";
    test2VC.ios_param1 = @"params";
    [self presentViewController:test2VC animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
