//
//  AppDelegate.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AppDelegate.h"

#import "BayMaxProtector.h"
#import "BayMaxDegradeAssist.h"
#import "WebViewController.h"

@interface AppDelegate ()<BayMaxDegradeAssistDataSource,BayMaxDegradeAssistDelegate>
{
    NSArray<NSString *> *_vcNames;
    NSArray<NSArray<NSDictionary *> *> *_params;
    NSArray<NSString *> *_urls;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*设置Assist的代理与数据源*/
    [BayMaxDegradeAssist Assist].degradeDelegate = self;
    [BayMaxDegradeAssist Assist].degradeDatasource = self;
    /*开启防护模式*/
    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
        /*unrecognizedSelector类型的错误，*/
        if (error.errorType == BayMaxErrorTypeUnrecognizedSelector) {
            NSLog(@"ErrorUnRecognizedSelInfos:%@",error.errorInfos);

        }else if (error.errorType == BayMaxErrorTypeTimer){
            NSLog(@"ErrorTimerinfos:%@",error.errorInfos);

            
        }else if (error.errorType == BayMaxErrorTypeKVO){
            NSLog(@"ErrorKVOinfos:%@",error.errorInfos);

            
        }else{
            NSLog(@"infos:%@",error.errorInfos);
        }
    }];
    /*开启某一指定防护*/
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
//    /*开启某几个组合防护*/
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector|BayMaxProtectionTypeTimer];
    //设置白名单
//    [BayMaxProtector ignoreProtectionsOnFrameworksWithPrefix:@[@"AV"]];
    [self requestConfigurationsFromWeb];
    return YES;
}

/*配置可以从服务器中获取,然后存到本地*/
- (void)requestConfigurationsFromWeb{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _vcNames = @[@"TestViewController",
                     @"Test2ViewController"];
        _params = @[
                    @[
                        @{@"H5_id":@"ios_ID"},
                        @{@"H5_typeid":@"ios_typeID"}
                        ],
                    @[
                        @{@"H5_param0":@"ios_param0"},
                        @{@"H5_param1":@"ios_param1"}
                        ]
                    ];
        
        _urls = @[
                  @"https://www.baidu.com",
                  @"https://www.sina.cn"
                  ];
        [[BayMaxDegradeAssist Assist]reloadRelations];
    });
}

#pragma mark BayMaxDegradeAssistDataSource
- (NSInteger)numberOfRelations{
    return 2;
}

- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index{
    return _vcNames[index];
}

- (NSArray<NSDictionary<NSString * , NSString *> *> *)correspondencesBetweenH5AndIOSParametersAtIndex:(NSInteger)index{
    return _params[index];
}

- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index{
    return _urls[index];
}

#pragma mark BayMaxDegradeAssistDelegate
- (void)degradeInstanceOfViewController:(UIViewController *)degradeVC ifErrorHappensInOtherProcessExceptViewDidLoadWithReplacedCompleteURL:(NSString *)completeURL relation:(NSDictionary *)relation{
    dispatch_async(dispatch_get_main_queue(), ^{
            [degradeVC.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            NSLog(@"completeUrl for %@ is %@",degradeVC,completeURL);
            NSLog(@"relation for %@ is %@",degradeVC,relation);
            //获取拼接后的url
            WebViewController *webVC = [[WebViewController alloc]init];
            webVC.url = completeURL;
            [degradeVC addChildViewController:webVC];
            [degradeVC.view addSubview:webVC.view];
        });
}

- (void)degradeClassOfViewController:(Class)degradeCls ifErrorHappensInViewDidLoadProcessWithReplacedURL:(NSString *)URL relation:(NSDictionary *)relation{
    NSLog(@"Url for %@ is %@",degradeCls,URL);
    WebViewController *webVC = [[WebViewController alloc]init];
    webVC.url = URL;
    UIViewController *vc = [[BayMaxDegradeAssist Assist]topViewController];
    [vc presentViewController:webVC animated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
