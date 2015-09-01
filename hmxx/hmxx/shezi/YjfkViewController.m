//
//  YjfkViewController.m
//  hmjz
//
//  Created by yons on 14-11-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "YjfkViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"


@interface YjfkViewController (){
    MKNetworkEngine *engine;
}

@end

@implementation YjfkViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"意见反馈";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        
        self.mytextview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.mytextview setFrame:CGRectMake(self.mytextview.frame.origin.x, self.mytextview.frame.origin.y, [UIScreen mainScreen].bounds.size.width-40, self.mytextview.frame.size.height)];
    }else{
        [self.mytextview setFrame:CGRectMake(20, 15, self.mytextview.frame.size.width, self.mytextview.frame.size.height)];
    }
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //设置导航栏右侧按钮
//    UIImage* image= [UIImage imageNamed:@"ic_sz_002.png"];
//    CGRect frame= CGRectMake(0, 0, 20, 20);
//    UIButton* someButton= [[UIButton alloc] initWithFrame:frame];
//    [someButton addTarget:self action:@selector(feecback) forControlEvents:UIControlEventTouchUpInside];
//    [someButton setBackgroundImage:image forState:UIControlStateNormal];
//    [someButton setShowsTouchWhenHighlighted:NO];
//    UIBarButtonItem *someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:someButton];
//    [self.navigationItem setRightBarButtonItem:someBarButtonItem];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"提交"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(feecback)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //初始化文本域
    self.mytextview.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.mytextview.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.mytextview.layer.borderWidth = 0.4f;
    self.mytextview.layer.cornerRadius = 5.0f;
    self.mytextview.autoresizingMask = UIViewAutoresizingNone;
    self.mytextview.scrollEnabled = YES;
    self.mytextview.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    self.mytextview.returnKeyType = UIReturnKeyDefault;
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    self.mytextview.backgroundColor = [UIColor whiteColor];
    [self.mytextview.layer setMasksToBounds:YES];
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
    
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [self.mytextview setText:[NSString stringWithFormat:@"设备: %@,系统: %@,应用名称：%@,客户端版本:%@,",phoneModel,phoneVersion,appCurName,appCurVersion]];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self.mytextview becomeFirstResponder];
}

- (void)textViewDidChangeSelection:(UITextView *)textView

{
//    NSRange range;
//    range.location = 0;
//    range.length = 0;
//    _textView.selectedRange = range;
}


- (void)feecback{
    [self.mytextview resignFirstResponder];
    if (self.mytextview.text.length == 0) {
        [self showHint:@"请填写内容"];
    }else{
        [self showHudInView:self.view hint:@""];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:self.mytextview.text forKey:@"feedbackcontent"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/Feedback/savafback.do" params:dic httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
            //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
            if ([success boolValue]) {
                [self hideHud];
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                [self showHint:@"提交成功" customView:imageview];
                self.mytextview.text = @"";
            }else{
                [self hideHud];
                [self showHint:@"提交失败"];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [self hideHud];
            
        }];
        [engine enqueueOperation:op];
    }
}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.mytextview resignFirstResponder];
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
