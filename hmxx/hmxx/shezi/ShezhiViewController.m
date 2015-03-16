//
//  ShezhiViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ShezhiViewController.h"
#import "LoginViewController.h"
#import "YjfkViewController.h"
#import "UpdatePasswordViewController.h"
#import "LoginViewController.h"
#import "MKNetworkKit.h"

@interface ShezhiViewController (){
    NSString *trackViewUrl;
    MKNetworkEngine *engine;
    UIActivityIndicatorView *indicatorView;
}

@end

@implementation ShezhiViewController
@synthesize alert;
@synthesize alert2;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    [self.navigationController setNavigationBarHidden:NO];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:@"itunes.apple.com" customHeaderFields:nil];
    
    [self drawTableView];
}

-(void)drawTableView{
    UITableView *tview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStyleGrouped];
    [tview setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]];
    [tview setDelegate:self];
    [tview setDataSource:self];
    [tview setScrollEnabled:YES];
    [self.view addSubview:tview];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [engine cancelAllOperations];
    alert = nil;
    alert2 = nil;
    NSLog(@"viewDidDisappear");
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [engine cancelAllOperations];
    alert = nil;
    alert2 = nil;
    NSLog(@"viewWillDisappear");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            YjfkViewController *vc = [[YjfkViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1){
            UpdatePasswordViewController *vc = [[UpdatePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2){
            [self checkUpdateWithAPPID:@"957244616"];//学校
        }else if (indexPath.row == 3){
            [self showStoreProductInApp:@"957244616"];
        }
    }else{
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
            alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            [alert addAction:[UIAlertAction actionWithTitle:@"退出登录"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action) {
                                                        [self loginout];
                                                    }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];
            actionsheet.tag = 100;
            [actionsheet showInView:self.view];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        switch (section) {
            case 0:
                if(row == 0)
                {
                    cell.textLabel.text =  @"意见反馈";
                }else if(row == 1){
                    cell.textLabel.text =  @"修改密码";
                }
                else if(row == 2){
                    cell.textLabel.text =  @"版本更新";
                }
                else if(row == 3){
                    cell.textLabel.text =  @"去评分";
                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text =  @"退出登录";
                [cell.textLabel setTextColor:[UIColor redColor]];
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                break;
            efault:
                break;
        }
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            [self loginout];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==10000) {
        if (buttonIndex==1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
        }
    }
}

#pragma mark - private

- (void)checkUpdateWithAPPID:(NSString *)APPID{
    [self showIndicator];
    //获取当前应用版本号
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [appInfo objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:APPID forKey:@"id"];
    MKNetworkOperation *op = [engine operationWithPath:@"/cn/lookup" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (jsonData == nil) {
            NSLog(@"json parse failed \r\n");
        }
        [self hideIndicator];
        NSArray *infoArray = [jsonData objectForKey:@"results"];
        if ([infoArray count]) {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
            NSString *releaseNotes = [releaseInfo objectForKey:@"releaseNotes"];
            if (![lastVersion isEqualToString:currentVersion]) {
                trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                    alert = [UIAlertController alertControllerWithTitle:@"立即更新" message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"立即更新"
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *action) {
                                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
                                                            }]];
                    [alert addAction:[UIAlertAction actionWithTitle:@"以后再说"
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action) {
                                                            }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }else{
                    alert2 = [[UIAlertView alloc] initWithTitle:@"立即更新" message:releaseNotes delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"立即更新", nil];
                    alert2.tag = 10000;
                    [alert2 show];
                }
            }
            else{
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                    alert = [UIAlertController alertControllerWithTitle:@"更新" message:@"此版本为最新版本" preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                              style:UIAlertActionStyleDestructive
                                                            handler:^(UIAlertAction *action) {
                                                            }]];
                    [self presentViewController:alert animated:YES completion:nil];
                }else{
                    alert2 = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert2.tag = 10001;
                    [alert2 show];
                }
                NSLog(@"1");
            }
        }else{
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                alert = [UIAlertController alertControllerWithTitle:@"更新" message:@"没有获取到版本信息" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:^(UIAlertAction *action) {
                                                        }]];
                NSLog(@"alert:%@",alert);
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                alert2 = [[UIAlertView alloc] initWithTitle:@"更新" message:@"没有获取到版本信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert2.tag = 10001;
                NSLog(@"alert2:%@",alert2);
                [alert2 show];
            }
            NSLog(@"2");
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideIndicator];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
            alert = [UIAlertController alertControllerWithTitle:@"更新" message:@"没有获取到版本信息" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action) {
                                                    }]];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            alert2 = [[UIAlertView alloc] initWithTitle:@"更新" message:@"没有获取到版本信息" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert2.tag = 10001;
            [alert2 show];
        }
    }];
    [engine enqueueOperation:op];
}

//查看app商店信息
- (void)showStoreProductInApp:(NSString *)appID{
    Class isAllow = NSClassFromString(@"SKStoreProductViewController");
    [self showIndicator];
    if (isAllow != nil) {
        SKStoreProductViewController *sKStoreProductViewController = [[SKStoreProductViewController alloc] init];
        [sKStoreProductViewController.view setFrame:CGRectMake(0, 200, 320, 200)];
        [sKStoreProductViewController setDelegate:self];
        [sKStoreProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: appID}
                                                completionBlock:^(BOOL result, NSError *error) {
                                                    if (result) {
                                                        [self hideIndicator];
                                                        [self presentViewController:sKStoreProductViewController
                                                                           animated:YES
                                                                         completion:nil];
                                                        
                                                        
                                                    }else{
                                                        [self hideIndicator];
                                                        NSString *des = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];
                                                        NSLog(@"error:%@",error);
                                                        NSLog(@"%@",des);
                                                    }
                                                }];
    }
//    else{
//        //低于iOS6的系统版本没有这个类,不支持这个功能
//        NSString *string = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/hui-min-jia-yuan-tong-jiao/id%@?mt=8&uo=4",appID];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
//    }
}

-(void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//加载等待视图
- (void)showIndicator{
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin
    | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:indicatorView];
    [indicatorView sizeToFit];
    [indicatorView startAnimating];
    indicatorView.center = self.view.center;
}

- (void)hideIndicator{
    [indicatorView stopAnimating];
}

-(void)loginout{
    //退出登陆
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"NO" forKey:@"LOGINED"];
    [self.navigationController setNavigationBarHidden:YES];
    UIViewController *rootVc = [self.navigationController.viewControllers objectAtIndex:0];
    if ([rootVc isKindOfClass:[LoginViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        LoginViewController *loginvc =  [[LoginViewController alloc] init];
        UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:loginvc];
        [vc setNavigationBarHidden:YES];
        self.view.window.rootViewController = vc;
    }
    
    
    
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
