//
//  CwjDetailViewController.m
//  hmjs
//
//  Created by yons on 15-1-28.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "CwjDetailViewController.h"
#import "QCheckBox.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"

@interface CwjDetailViewController ()<QCheckBoxDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    
    QCheckBox *oldButton;
}

@end

@implementation CwjDetailViewController
@synthesize info;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSLog(@"%d",self.indexpath.row);
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    CGRect rect = self.temperatureText.frame;
    rect.size.height = 40;
    self.temperatureText.frame = rect;
    
    rect = self.mobileText.frame;
    rect.size.height = 40;
    self.mobileText.frame = rect;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    NSString *studentName = [info objectForKey:@"studentName"];
    NSString *temperature = [info objectForKey:@"temperature"];
    NSString *mobile = [info objectForKey:@"mobile"];
    NSString *detail = [info objectForKey:@"detail"];
    NSNumber *situationtype = [info objectForKey:@"situationtype"];
    
    self.nameLabel.text = studentName;
    self.mobileText.text = mobile;
    self.mytextview1.text = detail;
    if (![Utils isBlankString:temperature] && ![temperature isEqualToString:@"0"]) {
        self.temperatureText.text = [NSString stringWithFormat:@"%.1f",[temperature floatValue]];
    }
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat checkBoxWidth = 70;
    
    QCheckBox *_check1 = [[QCheckBox alloc] initWithDelegate:self normal:[UIImage imageNamed:@"btn_zc.png"] selected:[UIImage imageNamed:@"btn_normal.png"]];
    _check1.tag = 1;
    _check1.frame = CGRectMake((width-checkBoxWidth)/2 - 100, 102, checkBoxWidth, 40);
    [_check1 setTitle:@"正常" forState:UIControlStateNormal];
    [_check1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_check1.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [_check1 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_check1];
    
    QCheckBox *_check2 = [[QCheckBox alloc] initWithDelegate:self normal:[UIImage imageNamed:@"btn_yc.png"] selected:[UIImage imageNamed:@"btn_normal.png"]];
    _check2.tag = 3;
    _check2.frame = CGRectMake((width-checkBoxWidth)/2, 102, checkBoxWidth, 40);
    [_check2 setTitle:@"异常" forState:UIControlStateNormal];
    [_check2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_check2.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [_check2 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_check2];
    
    QCheckBox *_check3 = [[QCheckBox alloc] initWithDelegate:self normal:[UIImage imageNamed:@"btn_qq.png"] selected:[UIImage imageNamed:@"btn_normal.png"]];
    _check3.tag = 2;
    _check3.frame = CGRectMake((width-checkBoxWidth)/2 + 100, 102, checkBoxWidth, 40);
    [_check3 setTitle:@"缺勤" forState:UIControlStateNormal];
    [_check3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_check3.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [_check3 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_check3];
    _check1.userInteractionEnabled = NO;
    _check2.userInteractionEnabled = NO;
    _check3.userInteractionEnabled = NO;
    
    
    if ([situationtype intValue] == 1) {
        [_check1 setChecked:YES];
        oldButton = _check1;
    }else if ([situationtype intValue] == 2) {
        [_check3 setChecked:YES];
        oldButton = _check3;
    }else if ([situationtype intValue] == 3) {
        [_check2 setChecked:YES];
        oldButton = _check2;
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [_check1 setFrame:CGRectMake(_check1.frame.origin.x, _check1.frame.origin.y-64, _check1.frame.size.width, _check1.frame.size.height)];
        [_check2 setFrame:CGRectMake(_check2.frame.origin.x, _check2.frame.origin.y-64, _check2.frame.size.width, _check2.frame.size.height)];
        [_check3 setFrame:CGRectMake(_check3.frame.origin.x, _check3.frame.origin.y-64, _check3.frame.size.width, _check3.frame.size.height)];
    }
    
//    self.mytextview1.layer.backgroundColor = [[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1] CGColor];
    self.saveBtn.layer.cornerRadius = 5.0f;
    self.mytextview1.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.mytextview1.layer.borderWidth = 0.7;
    self.mytextview1.layer.cornerRadius = 5.0f;
    [self.mytextview1.layer setMasksToBounds:YES];
    

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

- (IBAction)save:(id)sender {
    
    
    
    if (!oldButton) {
        [self alertMsg:@"请选择健康状态"];
        return ;
    }
    
    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:[info objectForKey:@"examinetype"] forKey:@"examinetype"];
    [dic setValue:[info objectForKey:@"id"] forKey:@"id"];
    [dic setValue:[NSString stringWithFormat:@"%d",oldButton.tag] forKey:@"situationtype"];
    if (self.temperatureText.text.length != 0) {
        [dic setValue:self.temperatureText.text forKey:@"temperature"];
    }
    [dic setValue:self.mytextview1.text forKey:@"detail"];
    [dic setValue:self.mobileText.text forKey:@"mobile"];
    [dic setValue:[info objectForKey:@"sort"] forKey:@"sort"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/examine/update.do" params:dic httpMethod:@"POST"];
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
            [self okMsk:msg];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0];
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

#pragma mark - private
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

-(void)click:(QCheckBox *)button{
    if (button.tag != oldButton.tag) {
        [oldButton setChecked:NO];
    }
    if ([button checked]) {
        oldButton = button;
    }else{
        oldButton = nil;
    }
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCwj" object:self.indexpath];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadCwjVc" object:nil];
}
@end
