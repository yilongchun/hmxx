//
//  YqjsViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "YqjsViewController.h"
#import"MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface YqjsViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
}

@end

@implementation YqjsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        self.edgesForExtendedLayout =  UIRectEdgeNone;
//    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
    }else{
        [self.mywebview setFrame:CGRectMake(self.mywebview.frame.origin.x, 0, self.mywebview.frame.size.width, self.mywebview.frame.size.height+64+49)];
    }
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"加载中...";
    
    [self getInfo];
}

//查询园情介绍
- (void)getInfo{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
    [dic setValue:schoolid forKey:@"schoolId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/School/findschoolbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            NSString *introduce = [data objectForKey:@"introduce"];
            NSString* fileid = [data objectForKey:@"fileid"];
            NSMutableString* htmlStr = [NSMutableString string];
            if (![Utils isBlankString:fileid]) {
                [htmlStr appendFormat:@"<head></head><p><img src='%@' width='%f'  /></p>",fileid,[[UIScreen mainScreen] bounds].size.width-20];
            }
            [htmlStr appendString:introduce];
            [self.mywebview loadHTMLString:htmlStr baseURL:[NSURL URLWithString:[Utils getHostname]]];
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1.0];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.0];
    }];
    [engine enqueueOperation:op];
}

- (void)webViewDidStartLoad:(UIWebView *)web{
    [HUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)web{
    [HUD hide:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
