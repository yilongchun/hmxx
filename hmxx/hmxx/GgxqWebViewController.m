//
//  GgxqWebViewController.m
//  hmjz
//
//  Created by yons on 15-8-14.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "GgxqWebViewController.h"
#import "AFNetworking.h"
#import "UIViewController+HUD.h"
#import "GgxqViewController.h"

@interface GgxqWebViewController ()

@end

@implementation GgxqWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStylePlain target:self action:@selector(toPingLun)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self loadData];
}

-(void)toPingLun{
    GgxqViewController *vc = [[GgxqViewController alloc] init];
    vc.tnid = self.tnid;
    vc.type = self.type;
    vc.title = @"公告评论";
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  初始化
 */
- (void)loadData{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:userid forKey:@"userId"];
    [dic setValue:self.tnid forKey:@"tnid"];
    
    [self showHudInView:self.view hint:@"加载中"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Notice/findbyid.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSNumber *success = [dic objectForKey:@"success"];
        if ([success boolValue]) {
            NSDictionary *data = [dic objectForKey:@"data"];
            if (data != nil) {
                NSString *tncontent = [data objectForKey:@"tncontent"];
                [self.myWebView loadHTMLString:tncontent baseURL:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
        
    }];
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
