//
//  AddBwrzViewController.m
//  hmjs
//
//  Created by yons on 14-12-9.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AddBwrzViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface AddBwrzViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    
    int studentnum;
}

@end

@implementation AddBwrzViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = self.bjrs.frame;
    rect.size.height = 40;
    self.bjrs.frame = rect;
    
    rect = self.cqrs.frame;
    rect.size.height = 40;
    self.cqrs.frame = rect;
    
    rect = self.bjrs2.frame;
    rect.size.height = 40;
    self.bjrs2.frame = rect;
    
    rect = self.sjrs.frame;
    rect.size.height = 40;
    self.sjrs.frame = rect;
    
    rect = self.cdrs.frame;
    rect.size.height = 40;
    self.cdrs.frame = rect;
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
//    self.bjsj.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
//    self.bjsj.layer.borderWidth = 1.0;
//    self.bjsj.layer.cornerRadius = 5.0f;
//    self.bjsj.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    [self.bjsj.layer setMasksToBounds:YES];
    
    
    
    self.bjsj.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.bjsj.layer.borderWidth = 1.0;
    self.bjsj.layer.cornerRadius = 5.0f;
    self.bjsj.scrollEnabled = YES;
    self.bjsj.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    self.bjsj.returnKeyType = UIReturnKeyDefault;
    self.bjsj.delegate = self;
    [self.bjsj.layer setMasksToBounds:YES];
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.bjsj.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.label1 setFrame:CGRectMake(self.label1.frame.origin.x, self.label1.frame.origin.y-64, self.label1.frame.size.width, self.label1.frame.size.height)];
        [self.label2 setFrame:CGRectMake(self.label2.frame.origin.x, self.label2.frame.origin.y-64, self.label2.frame.size.width, self.label2.frame.size.height)];
        [self.label3 setFrame:CGRectMake(self.label3.frame.origin.x, self.label3.frame.origin.y-64, self.label3.frame.size.width, self.label3.frame.size.height)];
        [self.label4 setFrame:CGRectMake(self.label4.frame.origin.x, self.label4.frame.origin.y-64, self.label4.frame.size.width, self.label4.frame.size.height)];
        [self.label5 setFrame:CGRectMake(self.label5.frame.origin.x, self.label5.frame.origin.y-64, self.label5.frame.size.width, self.label5.frame.size.height)];
        [self.label6 setFrame:CGRectMake(self.label6.frame.origin.x, self.label6.frame.origin.y-64, self.label6.frame.size.width, self.label6.frame.size.height)];
        
        [self.bjrs setFrame:CGRectMake(self.bjrs.frame.origin.x, self.bjrs.frame.origin.y-64, self.bjrs.frame.size.width, self.bjrs.frame.size.height)];
        [self.cqrs setFrame:CGRectMake(self.cqrs.frame.origin.x, self.cqrs.frame.origin.y-64, self.cqrs.frame.size.width, self.cqrs.frame.size.height)];
        [self.bjrs2 setFrame:CGRectMake(self.bjrs2.frame.origin.x, self.bjrs2.frame.origin.y-64, self.bjrs2.frame.size.width, self.bjrs2.frame.size.height)];
        [self.sjrs setFrame:CGRectMake(self.sjrs.frame.origin.x, self.sjrs.frame.origin.y-64, self.sjrs.frame.size.width, self.sjrs.frame.size.height)];
        [self.cdrs setFrame:CGRectMake(self.cdrs.frame.origin.x, self.cdrs.frame.origin.y-64, self.cdrs.frame.size.width, self.cdrs.frame.size.height)];
        [self.bjsj setFrame:CGRectMake(self.bjsj.frame.origin.x, self.bjsj.frame.origin.y-64, self.bjsj.frame.size.width, 130)];
        [self.dateTitleLabel setFrame:CGRectMake(self.dateTitleLabel.frame.origin.x, self.dateTitleLabel.frame.origin.y-64, self.dateTitleLabel.frame.size.width, self.dateTitleLabel.frame.size.height)];
        
    }
    
    //增加监听，当键盘出现或改变时收出消息
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    //增加监听，当键退出时收出消息
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
    

    self.title = @"添加校务日志";
    
    //添加手势，点击输入框其他区域隐藏键盘
//    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
//    tapGr.cancelsTouchesInView =NO;
//    [self.view addGestureRecognizer:tapGr];
    
    //添加按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    NSDate *date = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY年MM月dd日"];
    NSString *  locationString=[dateformatter stringFromDate:date];
    self.dateTitleLabel.text = locationString;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *schoolnum = [userDefaults objectForKey:@"schoolnum"];
    
    self.bjrs.text = [NSString stringWithFormat:@"%d",[schoolnum intValue]];
    
    studentnum = [schoolnum intValue];
}

//隐藏键盘
//-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
//    [self.bjsj resignFirstResponder];
//    [self.cqrs resignFirstResponder];
//    [self.bjrs2 resignFirstResponder];
//    [self.sjrs resignFirstResponder];
//    [self.cdrs resignFirstResponder];
////    if(self.view.frame.origin.y == -80){
////        [self moveView:80];
////    }
//}

- (void)save{
//    [self viewTapped:nil];
    
    int num1 = [self.cqrs.text intValue];
    int num2 = [self.bjrs2.text intValue];
    int num3 = [self.sjrs.text intValue];
    int num4 = [self.cdrs.text intValue];
    
    if (studentnum != (num1 + num2 + num3 + num4)) {
        [self alertMsg:@"总人数不等于教职人数"];
    }else{
        [HUD show:YES];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:schoolid forKey:@"recordId"];
        [dic setValue:[userDefaults objectForKey:@"userid"] forKey:@"userid"];
        [dic setValue:self.bjsj.text forKey:@"dailycontent"];
        [dic setValue:self.cqrs.text forKey:@"attnum"];
        [dic setValue:self.bjrs2.text forKey:@"sicknum"];
        [dic setValue:self.sjrs.text forKey:@"casualnum"];
        [dic setValue:self.cdrs.text forKey:@"latenum"];
        [dic setValue:@"" forKey:@"fileid"];
        MKNetworkOperation *op = [engine operationWithPath:@"/SchoolDaily/save.do" params:dic httpMethod:@"POST"];
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
                [HUD hide:YES];
                self.bjsj.text = @"";
                self.cqrs.text = @"";
                self.bjrs2.text = @"";
                self.sjrs.text = @"";
                self.cdrs.text = @"";
                [self okMsk:msg];
                [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0f];
                
                
            }else{
                [HUD hide:YES];
//                self.bjsj.text = @"";
//                self.cqrs.text = @"";
//                self.bjrs2.text = @"";
//                self.sjrs.text = @"";
//                self.cdrs.text = @"";
                [self alertMsg:msg];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [HUD hide:YES];
            [self alertMsg:@"连接服务器失败"];
        }];
        [engine enqueueOperation:op];
    }
}

//成功
- (void)okMsk:(NSString *)msg{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
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




//#pragma mark - 输入框代理
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    if (textField.tag != 99) {
//        if(self.view.frame.origin.y == -80){
//            [self moveView:80];
//        }
//    }
//}
//
//- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    
//    if(textView.tag == 99){
//        if(self.view.frame.origin.y == 0){
//            [self moveView:-80];
//        }
//    }
//    return true;
//}
//
////当键盘出现或改变时调用
//- (void)keyboardWillShow:(NSNotification *)aNotification
//{
//    //获取键盘的高度
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
//    int height = keyboardRect.size.height;
//    NSLog(@"%d",height);
//}
//
////当键退出时调用
//- (void)keyboardWillHide:(NSNotification *)aNotification
//{
//    
//}
//
////界面根据键盘的显示和隐藏上下移动
//-(void)moveView:(float)move{
//    NSTimeInterval animationDuration = 1.0f;
//    CGRect frame = self.view.frame;
//    if(move == 0){
//        frame.origin.y =0;
//    }else{
//        frame.origin.y +=move;//view的X轴上移
//    }
//    [UIView beginAnimations:@"ResizeView" context:nil];
//    self.view.frame = frame;
//    [UIView setAnimationDuration:animationDuration];
//    self.view.frame = frame;
//    [UIView commitAnimations];//设置调整界面的动画效果
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回重新加载
-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadYwrz" object:nil];
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
