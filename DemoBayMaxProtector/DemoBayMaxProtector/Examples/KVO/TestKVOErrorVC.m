//
//  TestKVOErrorVC.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "TestKVOErrorVC.h"

@interface TestKVOErrorVC ()

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) CGFloat progress1;

@end

@implementation TestKVOErrorVC
{
    NSArray *_titleArray;
}
#pragma mark ======== Life Cycle ========
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleArray = @[
                    @"keypath重复监听",
                    @"移除了未注册的观察者",
                    @"移除了不存在的keypath",
                    @"keypath重复移除",
                    @"关闭kvo防护",
                    @"开启kvo防护"
                    ];
    [self setupSubviews];
    [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
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
        [self addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }else if (1001 == btnTag){
        [self removeObserver:self forKeyPath:@"progress1"];
    }else if (1002 == btnTag){
        [self removeObserver:self forKeyPath:@"undefinedProgress"];
    }else if (1003 == btnTag){
        [self removeObserver:self forKeyPath:@"progress"];
        [self removeObserver:self forKeyPath:@"progress"];
    }else if (1004 == btnTag){
        [BayMaxProtector closeProtectionsOn:BayMaxProtectionTypeKVO];
    }else if (1005 == btnTag){
        [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeKVO];
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
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 5;
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [self.view addSubview:btn];
    }
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

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"progress"];
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


