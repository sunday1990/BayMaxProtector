//
//  TestUnrecognizedSelVC.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestUnrecognizedSelVC.h"

@interface TestUnrecognizedSelVC ()
@end

@implementation TestUnrecognizedSelVC
{
    NSArray *_titleArray;
}
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _titleArray = @[
                    @"找不到btn响应事件",
                    @"找不到vc中的方法",
                    @"向null对象发送length消息",
                    @"关闭UnrecognizedSel防护",
                    @"开启UnrecognizedSel防护"
                    ];
    [self setupSubviews];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
- (void)btnClick:(UIButton *)btn{
    NSInteger btnTag = btn.tag;
    if (1000 == btnTag) {
    }else if (1001 == btnTag){
        [self performSelector:@selector(undefinedVCSelector)];
    }else if (1002 == btnTag){
        [[NSNull null]performSelector:@selector(length)];
    }else if (1003 == btnTag){
        [BayMaxProtector closeProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
    }else if (1004 == btnTag){
        [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
    }
}

#pragma mark ======== Private Methods ========
- (void)setupSubviews{
    CGFloat btnWidth = ([self getMaxLength]+8)>(WIDTH/2-24)?(WIDTH/2-24):([self getMaxLength]+8);
    CGFloat btnHeight = 44;
    CGFloat borderSpace = 12;
    CGFloat btnSpace = (WIDTH - 2 * borderSpace - 2 * btnWidth);
    for (int i = 0; i<_titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1000+i;
        [btn setTitle:_titleArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        btn.frame = CGRectMake(borderSpace + (btnSpace + btnWidth)*(i%2), 60+(btnHeight+borderSpace)*(i/2), btnWidth, btnHeight);
        if (i == 0) {
            [btn addTarget:self action:@selector(undefinedBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }else{
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        btn.layer.cornerRadius = 5;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [self.view addSubview:btn];
    }
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 250, WIDTH-20, 150)];
    tipLabel.font = [UIFont systemFontOfSize:14];
    tipLabel.textColor = [UIColor darkTextColor];
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"1、当未获取自动降级配置时，点击前三个按钮后，会拦阻异常，防止崩溃，但不会对该页面进行降级 \n 2、当获取自动降级配置后，再点击会跳转到该页面对应的H5页面，进行降级，展示掘金首页。\n 3、当关闭崩溃保护后，再次点击前三个按钮，会发生崩溃，可点击开启防护后，重新进行防护\n 4、如果有参数会获取参数。";
    [self.view addSubview:tipLabel];
}


- (CGFloat)getMaxLength{
    CGFloat maxLength = 0;
    for (int i = 0; i<_titleArray.count; i++) {
        CGFloat tempLength = [_titleArray[i] widthForFont:[UIFont systemFontOfSize:14]];
        if (tempLength>maxLength) {
            maxLength = tempLength;
        }
    }
    return maxLength;
}
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


