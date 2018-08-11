//
//  BayMaxDebugView.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/2/1.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxDebugView.h"

#define BMPScreenWidth  [UIScreen mainScreen].bounds.size.width
#define BMPScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface BayMaxDebugView ()

@property (nonatomic, strong) UIButton *bubbleView;
@property (nonatomic, strong) UIButton *dismissBtn;
@property (nonatomic, strong) NSMutableArray *errorInfos;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation BayMaxDebugView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
static BayMaxDebugView *_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)sharedDebugView{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        UIWindow *keyWindow = [self getWindow];
        [keyWindow addSubview:self.bubbleView];
        [keyWindow addSubview:self.textView];
        [keyWindow addSubview:self.dismissBtn];
    }
    return self;
}

#pragma mark ========= Event Responses =========
- (void)showDebugView{
    if (self.errorInfos.count == 0) {
        return;
    }
    NSMutableString *text = [NSMutableString string];
    [self.errorInfos enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [text appendString:[NSString stringWithFormat:@"%lu 、\n{\n",idx+1]];
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL * _Nonnull stop) {
            [text appendString:key];
            [text appendString:@":"];
            [text appendString:[NSString stringWithFormat:@"%@\n\n",obj]];
        }];
        [text appendString:@"}\n\n============================\n\n"];
        
    }];
    self.textView.hidden = self.dismissBtn.hidden = NO;
    self.textView.text = [NSString stringWithFormat:@"\n\n共为您捕获%lu条异常:\n\n\n%@",(unsigned long)self.errorInfos.count,text];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.textView.frame = CGRectMake(0, 0, BMPScreenWidth, BMPScreenHeight);
        self.dismissBtn.frame = CGRectMake(BMPScreenWidth-12-40, 12, 40, 40);
    }];
}

- (void)dismissDebugView{
    [self.errorInfos removeAllObjects];
    [_bubbleView setTitle:@"BayMax" forState:UIControlStateNormal];
    [_bubbleView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        self.textView.frame = CGRectMake(0, BMPScreenHeight, BMPScreenWidth, BMPScreenHeight);
        self.dismissBtn.frame = CGRectMake(BMPScreenWidth-12-40, BMPScreenHeight+12, 40, 40);

    }completion:^(BOOL finished) {
        self.textView.hidden = self.dismissBtn.hidden = YES;
        [self.textView endEditing:YES];
    }];
}

- (void) handlePan:(UIPanGestureRecognizer*) recognizer{
    CGPoint translation = [recognizer translationInView:[self getWindow]];//self.window.rootViewController.view
    CGFloat centerX = recognizer.view.center.x + translation.x;
    CGFloat thecenter = 0;
    recognizer.view.center=CGPointMake(centerX,
                                       recognizer.view.center.y+ translation.y);
    [recognizer setTranslation:CGPointZero inView:[self getWindow]];//self.window.rootViewController.view
    if(recognizer.state==UIGestureRecognizerStateEnded || recognizer.state==UIGestureRecognizerStateCancelled) {
        if(centerX > BMPScreenWidth/2) {
            thecenter = BMPScreenWidth-self.bubbleView.frame.size.width/2-12;
        }else{
            thecenter = self.bubbleView.frame.size.width/2+12;
        }
        [UIView animateWithDuration:0.3 animations:^{
            recognizer.view.center=CGPointMake(thecenter,
                                               recognizer.view.center.y + translation.y);
        }];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textView endEditing:YES];
}

#pragma mark ========= Private Methods =========

- (void)addErrorInfo:(NSDictionary *_Nonnull)errorInfo{
    [self.errorInfos addObject:errorInfo];
    NSString *num = [NSString stringWithFormat:@"%ld",self.errorInfos.count];
    [self.bubbleView setTitle:[NSString stringWithFormat:@"+%@",num] forState:UIControlStateNormal];
    [self.bubbleView setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
}

- (UIWindow *)getWindow{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    return keyWindow;
}

#pragma mark ========= Setters && Getters =========

- (void)setHidden:(BOOL)hidden{
    self.bubbleView.hidden = hidden;
}

- (UIButton *)bubbleView{
    if (!_bubbleView) {
        _bubbleView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bubbleView.frame = CGRectMake(BMPScreenWidth-12- 50, 30, 50, 50);
        _bubbleView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_bubbleView setTitle:@"BayMax" forState:UIControlStateNormal];
        [_bubbleView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _bubbleView.layer.cornerRadius = 10;
        _bubbleView.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [_bubbleView addTarget:self action:@selector(showDebugView) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [_bubbleView addGestureRecognizer:pan];
    }
    return _bubbleView;
}

- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc]init];
        _textView.frame = CGRectMake(0, BMPScreenHeight, BMPScreenWidth, BMPScreenHeight);
        _textView.backgroundColor = [UIColor whiteColor];
        _textView.hidden = YES;
        _textView.textColor = [UIColor blackColor];
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:14];
        
    }
    return _textView;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _dismissBtn.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        _dismissBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_dismissBtn setTitle:@"返回" forState:UIControlStateNormal];
        _dismissBtn.layer.cornerRadius = 10;
        _dismissBtn.frame = CGRectMake(BMPScreenWidth-12-40, BMPScreenHeight+12, 40, 40);
        _dismissBtn.hidden = YES;
        [_dismissBtn addTarget:self action:@selector(dismissDebugView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (NSMutableArray *)errorInfos{
    if (!_errorInfos) {
        _errorInfos = [NSMutableArray array];
    }
    return _errorInfos;
}

@end

