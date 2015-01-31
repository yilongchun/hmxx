//
//  AddNoticeViewController.m
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AddNoticeViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface AddNoticeViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
}


@end

@implementation AddNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = self.titleLabel.frame;
    rect.size.height = 40;
    self.titleLabel.frame = rect;
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y-64, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
        [self.contentTextview setFrame:CGRectMake(self.contentTextview.frame.origin.x, self.contentTextview.frame.origin.y-64, self.contentTextview.frame.size.width, self.contentTextview.frame.size.height)];
        [self.title1 setFrame:CGRectMake(self.title1.frame.origin.x, self.title1.frame.origin.y-64, self.title1.frame.size.width, self.title1.frame.size.height)];
        [self.title2 setFrame:CGRectMake(self.title2.frame.origin.x, self.title2.frame.origin.y-64, self.title2.frame.size.width, self.title2.frame.size.height)];
        
//        [self.btn2 setFrame:CGRectMake(self.btn2.frame.origin.x, self.btn2.frame.origin.y-64, self.btn2.frame.size.width, self.btn2.frame.size.height)];
//        
//        [self.btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    self.contentTextview.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.contentTextview.layer.borderWidth = 1.0;
    self.contentTextview.layer.cornerRadius = 5.0f;
    //    _textView.delegate = self;
    //    _textView.scrollEnabled = YES;
    //    self.contentTextview.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    //    _textView.returnKeyType = UIReturnKeyDefault;
    
    
    
    [self.contentTextview.layer setMasksToBounds:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    
    
//    self.btn2.layer.cornerRadius = 5.0f;
    
    self.title = @"发布公告";
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.titleLabel resignFirstResponder];
    [self.contentTextview resignFirstResponder];
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

- (IBAction)addBtn:(id)sender {
    [self save];
}

-(void)save{
    [self viewTapped:nil];
    if (self.titleLabel.text.length == 0) {
        [self alertMsg:@"请填写标题"];
    }else if(self.contentTextview.text.length == 0){
        [self alertMsg:@"请填写内容"];
    }else{
        [HUD show:YES];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *userid = [userDefaults objectForKey:@"userid"];
        NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
        
        [dic setValue:userid forKey:@"userid"];
        [dic setValue:schoolid forKey:@"schoolId"];
//        [dic setValue:@"3" forKey:@"noticetype"];
//        [dic setValue:status forKey:@"status"];
        [dic setValue:self.titleLabel.text forKey:@"noticetitle"];
        [dic setValue:self.contentTextview.text forKey:@"noticecontent"];
        [dic setValue:@"" forKey:@"fileid"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/schoolNotice/save.do" params:dic httpMethod:@"POST"];
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
                [HUD hide:YES];
                self.titleLabel.text = @"";
                self.contentTextview.text = @"";
                [self okMsk:@"保存成功"];
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGggl" object:nil];
            }else{
                [HUD hide:YES];
                [self alertMsg:@"保存失败"];
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

@end
