//
//  TestViewDidloadUnrecognizedSelVC.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/2.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestViewDidloadUnrecognizedSelVC.h"

@interface TestViewDidloadUnrecognizedSelVC ()

@end

@implementation TestViewDidloadUnrecognizedSelVC
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNull null]performSelector:@selector(length)];
    [self performSelector:@selector(abc)];
   
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, WIDTH-20, 150)];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor darkTextColor];
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"1、ViewDidload中发生两个错误，一个是向NSNull对象发送length消息，还有一个就是向ViewController发送abc消息，这些都是未曾定义，在它们的方法列表中找不到的方法。\n2、针对这种页面进行降级，可以取到对应页面的URL，但是它的参数暂时拿不到。\n 3、当获取到配置后，在进入该页面会直接展示对应的H5页面";
    [self.view addSubview:tipLabel];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end


