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
#import "UIImageView+AFNetworking.h"

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
    
    self.title = @"教师信息";
    
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
                NSString *teacherName = [data objectForKey:@"teacherName"];
                NSString *flieid = [data objectForKey:@"flieid"];
                NSArray *classList = [data objectForKey:@"classList"];
                NSDictionary *classDic = [classList objectAtIndex:0];
                NSNumber *ishead = [classDic objectForKey:@"ishead"];
                self.username.text = [NSString stringWithFormat:@"%@",teacherName];
                if ([Utils isBlankString:flieid]) {
                    [self.userimage setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
                }else{
                    [self.userimage setImageWithURL:[NSURL URLWithString:flieid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
                }
                if ([ishead boolValue]) {
                    self.userjob.text = [NSString stringWithFormat:@"%@",@"班主任"];
                }else{
                    self.userjob.text = [NSString stringWithFormat:@"%@",@"教师"];
                }
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
    [hud hide:YES afterDelay:1.0];
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
