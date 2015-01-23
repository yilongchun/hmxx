//
//  JsfcDetailViewController.m
//  hmxx
//
//  Created by yons on 15-1-23.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "JsfcDetailViewController.h"
#import "Utils.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"

@interface JsfcDetailViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
}

@end

@implementation JsfcDetailViewController
@synthesize detailId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [self loadData];
}

-(void)loadData{
    [HUD show:YES];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:detailId forKey:@"id"];
    MKNetworkOperation *op = [engine operationWithPath:@"/teacherelegant/findById.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
//                NSString *title = [data objectForKey:@"title"];
//                NSString *daily_type = [data objectForKey:@"daily_type"];
//                NSString *content = [data objectForKey:@"content"];
//                if ([daily_type isEqualToString:@"1"]) {
//                    self.scheduleTypeSegmented.selectedSegmentIndex = 0;
//                }else if([daily_type isEqualToString:@"2"]){
//                    self.scheduleTypeSegmented.selectedSegmentIndex = 1;
//                }
//                self.titleLabel.text = title;
//                self.mytextview.text = content;
                [HUD hide:YES];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
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
