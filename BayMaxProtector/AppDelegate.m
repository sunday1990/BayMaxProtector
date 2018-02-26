//
//  AppDelegate.m
//  BayMaxProtector
//
//  Created by ccSunday on 2018/1/15.
//  Copyright © 2018年 ccSunday. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "BayMaxProtector.h"
#import "BayMaxDegradeAssist.h"
#import "WebViewController.h"

@interface AppDelegate ()
{
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[ViewController alloc]init];
    [self.window makeKeyAndVisible];

    /*开启防护模式*/
    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeAll catchErrorHandler:^(BayMaxCatchError * _Nullable error) {
        /*unrecognizedSelector类型的错误，*/
        if (error.errorType == BayMaxErrorTypeUnrecognizedSelector) {
            NSLog(@"ErrorUnRecognizedSelInfos:%@",error.errorInfos);            

        }else if (error.errorType == BayMaxErrorTypeTimer){
            NSLog(@"ErrorTimerinfos:%@",error.errorInfos);

            
        }else if (error.errorType == BayMaxErrorTypeKVO){
            NSLog(@"ErrorKVOinfos:%@",error.errorInfos);

        }else if (error.errorType == BayMaxErrorTypeContainers){
            NSLog(@"ErrorContainersinfos:%@",error.errorInfos);
            
        }else{
            NSLog(@"infos:%@",error.errorInfos);
        }
    }];
    [BayMaxProtector showDebugView];
    /*开启某一指定防护*/
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector];
//    /*开启某几个组合防护*/
//    [BayMaxProtector openProtectionsOn:BayMaxProtectionTypeUnrecognizedSelector|BayMaxProtectionTypeTimer];
    //设置白名单
//    [BayMaxProtector ignoreProtectionsOnClassesWithPrefix:@[@"AV"]];
    return YES;
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
