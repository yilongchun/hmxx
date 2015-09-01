//
//  UpdatePasswordViewController.m
//  hmjz
//  修改密码
//  Created by yons on 14-11-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"

@interface UpdatePasswordViewController (){
    MKNetworkEngine *engine;
}


@end

@implementation UpdatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.title = @"修改密码";
    //添加按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(updatePassword)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    //设置文本框高度
    CGRect rect = self.oldPassword.frame;
    rect.size.height = 40;
    self.oldPassword.frame = rect;
    
    CGRect rect2 = self.password1.frame;
    rect2.size.height = 40;
    self.password1.frame = rect2;
    
    CGRect rect3 = self.password2.frame;
    rect3.size.height = 40;
    self.password2.frame = rect3;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
    }else{
        [self.oldPassword setFrame:CGRectMake(self.oldPassword.frame.origin.x, self.oldPassword.frame.origin.y-64, self.oldPassword.frame.size.width, self.oldPassword.frame.size.height)];
        [self.password1 setFrame:CGRectMake(self.password1.frame.origin.x, self.password1.frame.origin.y-64, self.password1.frame.size.width, self.password1.frame.size.height)];
        [self.password2 setFrame:CGRectMake(self.password2.frame.origin.x, self.password2.frame.origin.y-64, self.password2.frame.size.width, self.password2.frame.size.height)];
    }
    
    
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)updatePassword{
    [self viewTapped:nil];
    if(self.oldPassword.text.length == 0){
        [self showHint:@"请输入旧密码"];
        return;
    }
    if(self.password1.text.length == 0){
        [self showHint:@"请输入新密码"];
        return;
    }
    if(self.password2.text.length == 0){
        [self showHint:@"请再次输入新密码"];
        return;
    }
    if([self.password1.text isEqualToString:self.password2.text]){
        [self showHudInView:self.view hint:@""];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:self.oldPassword.text forKey:@"oldPassword"];
        [dic setValue:self.password1.text forKey:@"newPassword"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/User/updatePassword.do" params:dic httpMethod:@"POST"];
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
                [self hideHud];
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                [self showHint:msg customView:imageview];
                self.oldPassword.text = @"";
                self.password1.text = @"";
                self.password2.text = @"";
                
            }else{
                [self hideHud];
                [self showHint:msg];
            }
            
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [self hideHud];
            [self showHint:@"连接服务器失败"];
            
        }];
        [engine enqueueOperation:op];
    }else{
        [self showHint:@"两次的密码不一致"];
    }
    
}

#pragma mark - 键盘回车
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField.tag ==0 ) {
//        [self.password1 becomeFirstResponder];
//    }else if (textField.tag == 1) {
//        [self.password2 becomeFirstResponder];
//    }else if (textField.tag == 2){
//        [self viewTapped:nil];
//    }
//    return YES;
//}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.oldPassword resignFirstResponder];
    [self.password1 resignFirstResponder];
    [self.password2 resignFirstResponder];
    
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
