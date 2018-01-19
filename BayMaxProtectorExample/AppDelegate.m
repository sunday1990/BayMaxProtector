//
//  AppDelegate.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AppDelegate.h"
#import "BayMaxProtector.h"
#import "WebViewController.h"
#import "BayMaxDegradeHelper.h"

@interface AppDelegate ()<BayMaxDegradeHelperDelegate>
{
    NSArray<NSString *> *_vcNames;
    NSArray<NSArray<NSDictionary *> *> *_params;
    NSArray<NSString *> *_urls;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [BayMaxDegradeHelper sharedBayMaxDegradeHelper].degradeDelegate = self;
    
    /*开启全部防护*/
    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
        /*unrecognizedSelector类型的错误，*/
        if (error.errorType == BayMaxErrorTypeUnrecognizedSelector) {
            NSLog(@"ErrorUnrecognizedSelectorinfos:%@",error.errorInfos);
            UIViewController *vc = error.errorInfos[BMPErrorUnrecognizedSel_VC];
            //移除vc的所有视图
            //获取vc,读取配置信息
            //获取vc的对应参数
            //创建webviewcontroller作为vc的子视图
            dispatch_async(dispatch_get_main_queue(), ^{
                [vc.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                NSDictionary *relation = [[BayMaxDegradeHelper sharedBayMaxDegradeHelper]relationForViewController:vc.class];
                NSString *url = relation[BMPHelperKey_Url];
                NSArray <NSDictionary *>*params = relation[BMPHelperKey_Params];
                NSMutableString *appendString = [NSMutableString string];
                [appendString appendString:@"?"];
                [params enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *h5Param = obj.allKeys[0];
                    NSString *iosParam = obj[h5Param];
                    NSString *h5Value = [vc valueForKeyPath:iosParam];
                    //?key=x&key1=x1
                    //拼接字符串
                    [appendString appendString:h5Param];
                    [appendString appendString:@"="];
                    [appendString appendString:h5Value];
                    if (idx<params.count-1) {
                        [appendString appendString:@"&"];
                    }
                }];
                
                NSLog(@"url for %@ is %@",NSStringFromClass(vc.class),[url stringByAppendingString:appendString]);
                NSLog(@"relation params for %@ is %@",NSStringFromClass(vc.class),params);
                WebViewController *webVC = [[WebViewController alloc]init];
                webVC.url = url;
                [vc addChildViewController:webVC];
                [vc.view addSubview:webVC.view];
            });
            
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
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeKVO|BayMaxProtectionTypeTimer];
    //设置白名单
//    [BayMaxProtector ignoreProtectionsOnFrameworksWithPrefix:@[@"AV"]];
    
    [self updateConfigurationsFromWeb];
    
    return YES;
}


/*配置可以从服务器中获取,然后存到本地*/
- (void)updateConfigurationsFromWeb{
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
                  @"http://www.sqcapital.cn"
                  ];
        [[BayMaxDegradeHelper sharedBayMaxDegradeHelper]reloadRelations];
    });
}

- (NSInteger)numberOfRelations{
    return 2;
}

- (NSString *)nameOfViewControllerAtIndex:(NSInteger)index{
    return _vcNames[index];
}

- (NSArray *)paramsBetweenH5andIosAtIndex:(NSInteger)index{
    return _params[index];
}

- (NSString *)urlOfViewControllerAtIndex:(NSInteger)index{
    return _urls[index];
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
