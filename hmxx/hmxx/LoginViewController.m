//
//  LoginViewController.m
//  hmjz
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
//#import "MainViewController.h"
//#import "Utils.h"
//#import "ChooseClassViewController.h"




@interface LoginViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
//    MKNetworkEngine *engine;
    
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.navigationController.delegate = self;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }else{
        [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.loginBtn setBackgroundColor:[UIColor clearColor]];
        
    }
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil]];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    self.navigationController.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
//    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.loginBtn.layer.cornerRadius = 5.0f;
    
//    _mainController = [[MainViewController alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginusername = [userDefaults objectForKey:@"loginusername"];
    NSString *loginpassword = [userDefaults objectForKey:@"loginpassword"];
    
    self.username.text = loginusername;
    self.password.text = loginpassword;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if ([self.logintype isEqualToString:@"login"] && ![Utils isBlankString:self.username.text] && ![Utils isBlankString:self.password.text]) {
//        self.logintype = @"";
//        [self login:nil];
//    }
}

//登陆之后根据userid获取班级信息
//- (void)getClassInfo:(NSString *)userid{
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:userid forKey:@"userid"];
//    
//    MKNetworkOperation *op = [engine operationWithPath:@"/class/findAllList.do" params:dic httpMethod:@"GET"];
//    [op addCompletionHandler:^(MKNetworkOperation *operation) {
////        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
//        NSString *result = [operation responseString];
//        NSError *error;
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//        if (resultDict == nil) {
//            NSLog(@"json parse failed \r\n");
//        }
//        
//        NSNumber *success = [resultDict objectForKey:@"success"];
//        NSString *msg = [resultDict objectForKey:@"msg"];
//        
//        if ([success boolValue]) {
//            NSArray *array = [resultDict objectForKey:@"data"];
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            if ([array count] == 1) {//只有一个班级默认选择
//                NSDictionary *data = [array objectAtIndex:0];
//                
//                
//                [userDefaults setObject:data forKey:@"class"];//讲班级存入userdefaults
//                [userDefaults setObject:array forKey:@"classes"];
//                if (_mainController == nil) {
//                    _mainController = [[MainViewController alloc] init];
//                }
//                [userDefaults setObject:@"1" forKey:@"loginflag"];
//                [self.navigationController pushViewController:_mainController animated:YES];
//                [HUD hide:YES];
//            }else if([array count] > 1){//有多个班级需要用户选择
//                [userDefaults setObject:array forKey:@"classes"];//将多个班级存入userdefaults
//                
//                NSDictionary *class = [userDefaults objectForKey:@"class"];//从用户之前的设置读取已经选择的班级
//                NSString *tempclassid = [class objectForKey:@"id"];//取得班级id
//                [userDefaults setObject:@"1" forKey:@"loginflag"];
//                BOOL classflag = false;
//                for (int i = 0 ; i < [array count]; i++) {
//                    NSDictionary *data = [array objectAtIndex:i];
//                    NSString *classid = [data objectForKey:@"id"];
//                    if ([classid isEqualToString:tempclassid]) {
//                        classflag = true;//如果相等 说明之前已经选择过班级
//                        break;
//                    }
//                }
//                if (classflag) {//如果选择过班级 直接进入首页
//                    if (_mainController == nil) {
//                        _mainController = [[MainViewController alloc] init];;
//                    }
//                    
//                    [self.navigationController pushViewController:_mainController animated:YES];
//                    
//                }else{//如果没有选择过 跳转选择班级界面
//                    ChooseClassViewController *vc = [[ChooseClassViewController alloc] init];//跳转 需要用户选择班级
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//                [HUD hide:YES];
//            }else{
//                [HUD hide:YES];
//                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                hud.mode = MBProgressHUDModeText;
//                hud.labelText = @"没有获取到班级信息";
//                hud.margin = 10.f;
//                hud.removeFromSuperViewOnHide = YES;
//                [hud hide:YES afterDelay:1.5];
//            }
//            
//        }else{
//            [HUD hide:YES];
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = msg;
//            hud.margin = 10.f;
//            hud.removeFromSuperViewOnHide = YES;
//            [hud hide:YES afterDelay:1.5];
//        }
//    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
//        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
//        [HUD hide:YES];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"连接失败";
//        hud.margin = 10.f;
//        hud.removeFromSuperViewOnHide = YES;
//        [hud hide:YES afterDelay:1.5];
//    }];
//    [engine enqueueOperation:op];
//}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self moveView:0];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[LoginViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
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

#pragma mark - 输入框代理
-(void)textFieldDidBeginEditing:(UITextField *)textField{   //开始编辑时，整体上移
    if(textField.tag == 0){
        if(self.view.frame.origin.y == 0){
            [self moveView:-60];
        }
        
    }else if(textField.tag == 1){
        if(self.view.frame.origin.y == -60){
            [self moveView:-60];
        }else if(self.view.frame.origin.y == 0){
            [self moveView:-120];
        }
    }
}

#pragma mark - 键盘回车
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag==0) {
        [self.password becomeFirstResponder];
    }
    if (textField.tag==1) {
        [self viewTapped:nil];
    }
    return YES;
}
//界面根据键盘的显示和隐藏上下移动
-(void)moveView:(float)move{
    NSTimeInterval animationDuration = 1.0f;
    CGRect frame = self.view.frame;
    if(move == 0){
        frame.origin.y =0;
    }else{
        frame.origin.y +=move;//view的X轴上移
    }
    [UIView beginAnimations:@"ResizeView" context:nil];
    self.view.frame = frame;
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];//设置调整界面的动画效果
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

- (IBAction)login:(id)sender {
    if (self.username.text.length == 0) {
        [self alertMsg:@"请输入账号"];
        return;
    }else if (self.password.text.length == 0){
        [self alertMsg:@"请输入密码"];
        return;
    }
    
    
    [self viewTapped:nil];
//    HUD.labelText = @"登陆中...";
//    [HUD show:YES];
//    
//    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    [dic setValue:self.username.text forKey:@"userId"];
//    [dic setValue:self.password.text forKey:@"password"];
//    [dic setValue:@"2" forKey:@"clientType"];
//    [dic setValue:app_Version forKey:@"clientVersion"];
//    
//    
//    MKNetworkOperation *op = [engine operationWithPath:@"/app/Tlogin.do" params:dic httpMethod:@"POST"];
//    [op addCompletionHandler:^(MKNetworkOperation *operation) {
//        
//        NSString *result = [operation responseString];
//        NSError *error;
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//        if (resultDict == nil) {
//            NSLog(@"json parse failed \r\n");
//        }
//        
//        NSNumber *success = [resultDict objectForKey:@"success"];
//        NSString *msg = [resultDict objectForKey:@"msg"];
//        
//        if ([success boolValue]) {
//            NSDictionary *data = [resultDict objectForKey:@"data"];
//            NSString *userid = [data objectForKey:@"userid"];
//            NSString *hxusercode = [data objectForKey:@"hxusercode"];
//            NSString *hxpassword = [data objectForKey:@"hxpassword"];
//            
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//            [userDefaults setObject:userid forKey:@"userid"];
//            
//            [userDefaults setObject:self.username.text forKey:@"loginusername"];
//            [userDefaults setObject:self.password.text forKey:@"loginpassword"];
//            
//            
//            
//            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:hxusercode
//                                                                password:hxpassword
//                                                              completion:
//             ^(NSDictionary *loginInfo, EMError *error) {
//                 
//                 if (loginInfo && !error) {
//                     
//                     //                     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
//                     [_mainController setupUnreadMessageCount];
//                     
//                 }else {
//                     
//                     switch (error.errorCode) {
//                         case EMErrorServerNotReachable:
//                             [self alertMsg:@"连接服务器失败!"];
//                             NSLog(@"连接服务器失败!");
//                             break;
//                         case EMErrorServerAuthenticationFailure:
//                             [self alertMsg:@"用户名或密码错误"];
//                             NSLog(@"用户名或密码错误");
//                             break;
//                         case EMErrorServerTimeout:
//                             [self alertMsg:@"连接服务器超时!"];
//                             NSLog(@"连接服务器超时!");
//                             break;
//                         default:
//                             [self alertMsg:@"登录失败"];
//                             NSLog(@"登录失败");
//                             break;
//                     }
//                 }
//             } onQueue:nil];
//            
//            
//            
//            
//            
//            [self getClassInfo:userid];//获取班级信息
//            
//            
//        }else{
//            [HUD hide:YES];
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = msg;
//            hud.margin = 10.f;
//            hud.removeFromSuperViewOnHide = YES;
//            [hud hide:YES afterDelay:1.5];
//        }
//    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
//        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
//        [HUD hide:YES];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"连接失败";
//        hud.margin = 10.f;
//        hud.removeFromSuperViewOnHide = YES;
//        [hud hide:YES afterDelay:1.5];
//    }];
//    [engine enqueueOperation:op];
}
@end
