//
//  BayMaxDegradeAssist.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/19.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "BayMaxDegradeAssist.h"
#import "BayMaxCatchError.h"
#import "BayMaxCFunctions.h"

NSString *const BMPAssistKey_VC = @"BMP_ViewController";

NSString *const BMPAssistKey_Params = @"BMP_Params";

NSString *const BMPAssistKey_Url = @"BMP_Url";

NSString *const InitiativeMethodName = @"com.bayMaxProtector.degradeViewControllerInitiative";

static NSArray *_initiativeDegradeVCS;

@interface UIViewController (DegradeAssist)
@end

@implementation UIViewController (DegradeAssist)
- (void)BMDA_viewDidAppear:(BOOL)animated{
    id degradeDatasource = [BayMaxDegradeAssist Assist].degradeDatasource;
    if ([degradeDatasource respondsToSelector:@selector(viewControllersToDegradeInitiative)]) {
        NSArray *vcs = [degradeDatasource viewControllersToDegradeInitiative];
        if (![vcs isEqual:[NSNull null]]&&vcs.count>0) {
            [vcs enumerateObjectsUsingBlock:^(NSString *vcClsName, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([vcClsName isEqualToString:NSStringFromClass(self.class)]) {
                    BMP_SuppressPerformSelectorLeakWarning(                                                           
                                                           [self performSelector:NSSelectorFromString(InitiativeMethodName)];
                                                           );
                    NSLog(@"页面主动降级成功");
                }
            }];
        }else{
            [self BMDA_viewDidAppear:animated];
        }
    }else{
        [self BMDA_viewDidAppear:animated];
    }
}

@end


@implementation BayMaxDegradeAssist

static  BayMaxDegradeAssist*_instance;

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (nonnull instancetype)Assist{
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
        _relations = [NSMutableArray array];
    }
    return self;
}

- (void)reloadRelations{
    [self.relations removeAllObjects];
    id degradeDatasource = [BayMaxDegradeAssist Assist].degradeDatasource;
    if (degradeDatasource && [degradeDatasource respondsToSelector:@selector(viewControllersToDegradeInitiative)]) {
        _initiativeDegradeVCS = [degradeDatasource viewControllersToDegradeInitiative];
        if (_initiativeDegradeVCS.count>0) {
            BMP_EXChangeInstanceMethod([UIViewController class], @selector(viewDidAppear:), [UIViewController class], @selector(BMDA_viewDidAppear:));
        }
    }
    if (degradeDatasource && [degradeDatasource respondsToSelector:@selector(numberOfRelations)]) {
            NSInteger relations = [degradeDatasource numberOfRelations];
            for (int i = 0; i<relations; i++) {
                NSString *vcName;
                NSString *vcUrl;
                NSArray *params;
                if ([degradeDatasource respondsToSelector:@selector(nameOfViewControllerAtIndex:)]) {
                    vcName = [degradeDatasource nameOfViewControllerAtIndex:i];
                }
                if ([degradeDatasource respondsToSelector:@selector(urlOfViewControllerAtIndex:)]) {
                    vcUrl = [degradeDatasource urlOfViewControllerAtIndex:i];
                }
                if ([degradeDatasource respondsToSelector:@selector(correspondencesBetweenH5AndIOSParametersAtIndex:)]) {
                    
                    params = [degradeDatasource correspondencesBetweenH5AndIOSParametersAtIndex:i];
                }
                NSDictionary *item = @{
                                       BMPAssistKey_VC:vcName == nil?@"":vcName,
                                       BMPAssistKey_Url:vcUrl == nil?@"":vcUrl,
                                       BMPAssistKey_Params:params == nil?@"":params
                                       };
                [self.relations addObject:item];
            }
        if (relations>0) {
            NSLog(@"页面降级相关配置更新成功！");
        }

    }
}

- (NSDictionary *)relationForViewController:(Class)cls{
    __block NSDictionary *relation;
    NSString *clsName = NSStringFromClass(cls);
    [self.relations enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj objectForKey:BMPAssistKey_VC] isEqualToString:clsName]) {
            relation = obj;
            *stop = YES;
        }
    }];
    return relation;
}


#pragma mark BayMaxDegradeAssistProtocol
- (void)handleError:(BayMaxCatchError *)error{
    if (error.errorType == BayMaxErrorTypeUnrecognizedSelector) {
        id obj = error.errorInfos[BMPErrorUnrecognizedSel_VC];
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIViewController *vc = (UIViewController *)obj;
            NSString *completeURL = [[BayMaxDegradeAssist Assist]getCompleteUrlWithParamsForViewController:vc];
            if (completeURL.length>0) {
                NSDictionary *relation = [[BayMaxDegradeAssist Assist]relationForViewController:vc.class];
                id degradeDelegate = self.degradeDelegate;
                if (degradeDelegate && [degradeDelegate respondsToSelector:@selector(autoDegradeInstanceOfViewController:ifErrorHappensInProcessExceptViewDidLoadWithReplacedCompleteURL:relation:)]) {
                    [degradeDelegate autoDegradeInstanceOfViewController:vc ifErrorHappensInProcessExceptViewDidLoadWithReplacedCompleteURL:completeURL relation:relation];
                }
            }
        }else if([obj isKindOfClass:[NSString class]]){
            NSString *cls =(NSString *)obj;
            NSDictionary *relation = [[BayMaxDegradeAssist Assist]relationForViewController:NSClassFromString(obj)];
            NSString *URL = relation[BMPAssistKey_Url];
            if (URL.length>0) {
                id degradeDelegate = self.degradeDelegate;
                if (degradeDelegate && [degradeDelegate respondsToSelector:@selector(autoDegradeClassOfViewController:ifErrorHappensInViewDidLoadProcessWithReplacedURL:relation:)]) {
                    [degradeDelegate autoDegradeClassOfViewController:NSClassFromString(cls) ifErrorHappensInViewDidLoadProcessWithReplacedURL:URL relation:relation];
                }
            }
        }
    }
}

#pragma mark others
- (NSString *)getCompleteUrlWithParamsForViewController:(UIViewController *)vc{
    NSMutableString *appendString = [NSMutableString string];
    NSDictionary *relation = [self relationForViewController:[vc class]];
    NSString *url = relation[BMPAssistKey_Url];
    if (url == nil) {
        return @"";
    }
    NSArray <NSDictionary *>*params = relation[BMPAssistKey_Params];
    [appendString appendString:url];
    [appendString appendString:@"?"];
    [params enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *h5Param = obj.allKeys[0];
        NSString *iosParam = obj[h5Param];
        //keypath需要做判断
        NSString *h5Value = [vc valueForKeyPath:iosParam];
        if (h5Value) {
            [appendString appendString:h5Param];
            [appendString appendString:@"="];
            [appendString appendString:h5Value];
            if (idx<params.count-1) {
                [appendString appendString:@"&"];
            }
        }
    }];
    if ([appendString hasSuffix:@"?"]&&appendString.length>1) {
     return  [appendString substringWithRange:NSMakeRange(0, appendString.length-1)];
    }
    return appendString;        
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
