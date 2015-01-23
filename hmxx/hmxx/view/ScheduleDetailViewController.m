//
//  ScheduleDetailViewController.m
//  hmxx
//
//  Created by yons on 15-1-22.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ScheduleDetailViewController.h"
#import "Utils.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"

@interface ScheduleDetailViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
}

@end

@implementation ScheduleDetailViewController
@synthesize detailId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"日志详情";
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"修改"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.mytextview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.mytextview setFrame:CGRectMake(self.mytextview.frame.origin.x, self.mytextview.frame.origin.y, [UIScreen mainScreen].bounds.size.width-8-85, self.mytextview.frame.size.height)];
    }else{
        [self.label1 setFrame:CGRectMake(self.label1.frame.origin.x, self.label1.frame.origin.y-55, self.label1.frame.size.width, self.label1.frame.size.height)];
        [self.label2 setFrame:CGRectMake(self.label2.frame.origin.x, self.label2.frame.origin.y-44, self.label2.frame.size.width, self.label2.frame.size.height)];
        [self.label3 setFrame:CGRectMake(self.label3.frame.origin.x, self.label3.frame.origin.y-44, self.label3.frame.size.width, self.label3.frame.size.height)];
        [self.scheduleTypeSegmented setFrame:CGRectMake(self.scheduleTypeSegmented.frame.origin.x, self.scheduleTypeSegmented.frame.origin.y-64, self.scheduleTypeSegmented.frame.size.width, self.scheduleTypeSegmented.frame.size.height)];
        [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y-44, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
        [self.mytextview setFrame:CGRectMake(self.mytextview.frame.origin.x, self.mytextview.frame.origin.y-44, self.mytextview.frame.size.width, self.mytextview.frame.size.height)];
    }
    
    self.mytextview.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.mytextview.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.mytextview.layer.borderWidth = 0.5;
    self.mytextview.layer.cornerRadius = 5.0f;
    self.mytextview.autoresizingMask = UIViewAutoresizingNone;
    self.mytextview.scrollEnabled = YES;
    self.mytextview.returnKeyType = UIReturnKeyDefault;
    self.mytextview.backgroundColor = [UIColor whiteColor];
    [self.mytextview.layer setMasksToBounds:YES];
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    
    [self loadData];
}

-(void)loadData{
    [HUD show:YES];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:detailId forKey:@"id"];
    MKNetworkOperation *op = [engine operationWithPath:@"/busdaily/findbyid.do" params:dic httpMethod:@"GET"];
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
                NSString *title = [data objectForKey:@"title"];
                NSString *daily_type = [data objectForKey:@"daily_type"];
                NSString *content = [data objectForKey:@"content"];
                if ([daily_type isEqualToString:@"1"]) {
                    self.scheduleTypeSegmented.selectedSegmentIndex = 0;
                }else if([daily_type isEqualToString:@"2"]){
                    self.scheduleTypeSegmented.selectedSegmentIndex = 1;
                }
                self.titleLabel.text = title;
                self.mytextview.text = content;
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

-(void)save{
    [self.titleLabel resignFirstResponder];
    [self.mytextview resignFirstResponder];
    if (self.titleLabel.text.length == 0) {
        [self alertMsg:@"请填写日期标题"];
        return;
    }
    if (self.mytextview.text.length == 0) {
        [self alertMsg:@"请填写日志内容"];
        return;
    }
    
    [HUD show:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    if (self.scheduleTypeSegmented.selectedSegmentIndex == 0) {
        [dic setValue:@"1" forKey:@"dailyType"];
    }else if (self.scheduleTypeSegmented.selectedSegmentIndex == 1) {
        [dic setValue:@"2" forKey:@"dailyType"];
    }
    [dic setValue:detailId forKey:@"id"];
    [dic setValue:self.titleLabel.text forKey:@"title"];
    [dic setValue:self.mytextview.text forKey:@"content"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/busdaily/update.do" params:dic httpMethod:@"POST"];
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
            [self okMsk:msg];
            [HUD hide:YES];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0f];
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

//成功
- (void)okMsk:(NSString *)msg{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.delegate = self;
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:1.0];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDaily" object:nil];
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
