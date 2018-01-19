//
//  WebViewController.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/18.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>
@interface WebViewController ()
{
    WKWebView *_webview;
}
@end

@implementation WebViewController
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webview = [[WKWebView alloc]initWithFrame:self.view.bounds];
    _webview.backgroundColor = [UIColor yellowColor];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    request.timeoutInterval = 20;
    [_webview loadRequest:request];
    [self.view addSubview:_webview];
    
    UIButton *dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissBtn.frame = CGRectMake(12, 12, 40, 20);
    [dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
    [dismissBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    dismissBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [dismissBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dismissBtn];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
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


