//
//  AppDelegate.m
//  hmxx
//
//  Created by yons on 15-1-12.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "AppDelegate.h"
#import "GuideViewController.h"
#import "LoginViewController.h"
#import "IQKeyboardManager.h"
#import "Utils.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSLog(@"first launch第一次程序启动");
        GuideViewController *vc = [[GuideViewController alloc] init];
        self.window.rootViewController = vc;
    }else {
        NSLog(@"second launch再次程序启动");
        [self login];
    }
    [self.window makeKeyAndVisible];
    return YES;
    
}

-(void)login{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginusername = [userDefaults objectForKey:@"loginusername"];
    NSString *loginpassword = [userDefaults objectForKey:@"loginpassword"];
    NSString *logined = [userDefaults objectForKey:@"LOGINED"];
    
    if ([logined isEqualToString:@"YES"]) {//已经登陆
        if (![Utils isBlankString:loginusername] && ![Utils isBlankString:loginpassword]) {
            NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/app/Slogin.do?userId=%@&password=%@&clientType=%@&clientVersion=%@",[Utils getHostname],loginusername,loginpassword,@"2",app_Version]]];
            [request setHTTPMethod:@"GET"];
            NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:returnData options:0 error:nil];
            NSNumber *success = [resultDict objectForKey:@"success"];
            if ([success boolValue]) {
                NSDictionary *data = [resultDict objectForKey:@"data"];
                NSString *userid = [data objectForKey:@"userid"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:userid forKey:@"userid"];
                [userDefaults setObject:loginusername forKey:@"loginusername"];
                [userDefaults setObject:loginpassword forKey:@"loginpassword"];
                [userDefaults setObject:@"YES" forKey:@"LOGINED"];
                MainViewController *mainController = [[MainViewController alloc] init];
                UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:mainController];
                self.window.rootViewController = vc;
            }else{
                LoginViewController *loginvc =  [[LoginViewController alloc] init];
                loginvc.logintype = @"login";
                UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:loginvc];
                [vc setNavigationBarHidden:YES];
                self.window.rootViewController = vc;
            }
        }else{
            LoginViewController *loginvc =  [[LoginViewController alloc] init];
            loginvc.logintype = @"login";
            UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:loginvc];
            [vc setNavigationBarHidden:YES];
            self.window.rootViewController = vc;
        }
    }else{//未登陆
        LoginViewController *loginvc =  [[LoginViewController alloc] init];
        loginvc.logintype = @"login";
        UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:loginvc];
        [vc setNavigationBarHidden:YES];
        self.window.rootViewController = vc;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
