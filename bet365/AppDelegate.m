//
//  AppDelegate.m
//  bet365
//
//  Created by bet001 on 2018/8/10.
//  Copyright © 2018年 Bet365. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) MainViewController *mainVC;

@end

@implementation AppDelegate
static BOOL statusAlert = NO;  // 第一次连接有网络时不弹出提示

- (MainViewController *)mainVC {
    if (!_mainVC) {
        _mainVC = [[MainViewController alloc] init];
    }
    return _mainVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 使用 AFNetworkReachabilityManager 监听网络状况，并在没有网络的时候提醒
//    [self listenNetworkReachabilityStatus];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:self.mainVC];
    
    // 让当前 UIWindow 窗口变成 keyWiindow (主窗口)
//    [self.window makeKeyWindow];
    
    // 让当前 UIWindow 窗口变成 keyWiindow (主窗口)，并显示出来
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)listenNetworkReachabilityStatus {
    
    // 实例化 AFNetworkReachabilityManager
    AFNetworkReachabilityManager * afManager = [AFNetworkReachabilityManager sharedManager];
    
    /**
     判断网络状态并处理
     @param status 网络状态
     AFNetworkReachabilityStatusUnknown             = 未知网络
     AFNetworkReachabilityStatusNotReachable        = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN    = 蜂窝网络（3g、4g、wwan）
     AFNetworkReachabilityStatusReachableViaWiFi    = wifi网络
     */
    [afManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"当前网络状态未知");
                [self statusAlertWithNote:@"当前网络状态未知"];
                statusAlert = YES;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"网络已断开");
                [self statusAlertWithNote:@"网络已断开"];
                statusAlert = YES;
                break;
                
            default:
                NSLog(@"网络已连接");
                if (statusAlert) {
                    [self statusAlertWithNote:@"网络已连接"];
                    statusAlert = NO;
                }
                break;
        }
    }];
    
    // 开始监听
    [afManager startMonitoring];
}

- (void)statusAlertWithNote:(NSString *)note {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:note preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    
    [alertController addAction:action];
    
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
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
