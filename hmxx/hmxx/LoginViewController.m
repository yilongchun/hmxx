//
//  LoginViewController.m
//  hmxx
//
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "LoginViewController.h"
#import "MBProgressHUD.h"
#import "MKNetworkKit.h"
#import "Utils.h"

@interface LoginViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    
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
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];//设置系统返回按钮的颜色
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];//设置导航栏标题的颜色
    }else{
//        [self.loginBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [self.loginBtn setBackgroundColor:[UIColor clearColor]];
        
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
    
    [self.loginBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnBg.png"]stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[[UIImage imageNamed:@"loginBtnBg2.png"]stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateHighlighted];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.loginBtn.layer.cornerRadius = 5.0f;
    
    _mainController = [[MainViewController alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *loginusername = [userDefaults objectForKey:@"loginusername"];
    NSString *loginpassword = [userDefaults objectForKey:@"loginpassword"];
    
//    self.username.text = loginusername;
//    self.password.text = loginpassword;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    if ([self.logintype isEqualToString:@"login"] && ![Utils isBlankString:self.username.text] && ![Utils isBlankString:self.password.text]) {
//        self.logintype = @"";
//        [self login:nil];
//    }
}



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

- (IBAction)login:(id)sender{
    if (self.username.text.length == 0) {
        [self alertMsg:@"请输入账号"];
        return;
    }else if (self.password.text.length == 0){
        [self alertMsg:@"请输入密码"];
        return;
    }
    
    
    [self viewTapped:nil];
    HUD.labelText = @"请稍后...";
    [HUD show:YES];
    
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username.text forKey:@"userId"];
    [dic setValue:self.password.text forKey:@"password"];
    [dic setValue:@"2" forKey:@"clientType"];
    [dic setValue:app_Version forKey:@"clientVersion"];
    
    
    MKNetworkOperation *op = [engine operationWithPath:@"/app/Slogin.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        
        if ([success boolValue]) {
            [HUD hide:YES];
            
            NSDictionary *data = [resultDict objectForKey:@"data"];
            NSString *userid = [data objectForKey:@"userid"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userid forKey:@"userid"];
            [userDefaults setObject:self.username.text forKey:@"loginusername"];
            [userDefaults setObject:self.password.text forKey:@"loginpassword"];
            [userDefaults setObject:@"YES" forKey:@"LOGINED"];
//            if (_mainController == nil) {
                    _mainController = [[MainViewController alloc] init];;
//            }
            [self.navigationController pushViewController:_mainController animated:YES];
            
        }else{
            [HUD hide:YES];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = msg;
            hud.margin = 10.f;
            hud.removeFromSuperViewOnHide = YES;
            [hud hide:YES afterDelay:1.5];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"连接服务器失败";
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.5];
    }];
    [engine enqueueOperation:op];
}
@end
