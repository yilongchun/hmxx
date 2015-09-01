//
//  UpdateBwrzViewController.m
//  hmjs
//
//  Created by yons on 14-12-9.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "UpdateBwrzViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"

@interface UpdateBwrzViewController (){
    MKNetworkEngine *engine;
    
    int schoolnum;
}

@end

@implementation UpdateBwrzViewController

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
    
    
    
    
    
    self.bjsj.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.bjsj.layer.borderWidth = 1.0;
    self.bjsj.layer.cornerRadius = 5.0f;
    self.bjsj.scrollEnabled = YES;
    self.bjsj.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    self.bjsj.returnKeyType = UIReturnKeyDefault;
//    self.bjsj.delegate = self;
    [self.bjsj.layer setMasksToBounds:YES];
    self.bjsj.autoresizingMask = UIViewAutoresizingNone;
    self.title = @"校务日志详情";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.bjsj.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        self.automaticallyAdjustsScrollViewInsets = NO;
        NSLog(@"%f",self.bjsj.frame.size.height);
        [self.bjsj setFrame:CGRectMake(self.bjsj.frame.origin.x, self.bjsj.frame.origin.y, self.bjsj.frame.size.width, 130)];
        NSLog(@"%f",self.bjsj.frame.size.height);
    }else{
//        [self.label1 setFrame:CGRectMake(self.label1.frame.origin.x, self.label1.frame.origin.y-64, self.label1.frame.size.width, self.label1.frame.size.height)];
//        [self.label2 setFrame:CGRectMake(self.label2.frame.origin.x, self.label2.frame.origin.y-64, self.label2.frame.size.width, self.label2.frame.size.height)];
//        [self.label3 setFrame:CGRectMake(self.label3.frame.origin.x, self.label3.frame.origin.y-64, self.label3.frame.size.width, self.label3.frame.size.height)];
//        [self.label4 setFrame:CGRectMake(self.label4.frame.origin.x, self.label4.frame.origin.y-64, self.label4.frame.size.width, self.label4.frame.size.height)];
//        [self.label5 setFrame:CGRectMake(self.label5.frame.origin.x, self.label5.frame.origin.y-64, self.label5.frame.size.width, self.label5.frame.size.height)];
//        [self.label6 setFrame:CGRectMake(self.label6.frame.origin.x, self.label6.frame.origin.y-64, self.label6.frame.size.width, self.label6.frame.size.height)];
//        
//        [self.bjrs setFrame:CGRectMake(self.bjrs.frame.origin.x, self.bjrs.frame.origin.y-64, self.bjrs.frame.size.width, self.bjrs.frame.size.height)];
//        [self.cqrs setFrame:CGRectMake(self.cqrs.frame.origin.x, self.cqrs.frame.origin.y-64, self.cqrs.frame.size.width, self.cqrs.frame.size.height)];
//        [self.bjrs2 setFrame:CGRectMake(self.bjrs2.frame.origin.x, self.bjrs2.frame.origin.y-64, self.bjrs2.frame.size.width, self.bjrs2.frame.size.height)];
//        [self.sjrs setFrame:CGRectMake(self.sjrs.frame.origin.x, self.sjrs.frame.origin.y-64, self.sjrs.frame.size.width, self.sjrs.frame.size.height)];
//        [self.cdrs setFrame:CGRectMake(self.cdrs.frame.origin.x, self.cdrs.frame.origin.y-64, self.cdrs.frame.size.width, self.cdrs.frame.size.height)];
//        [self.bjsj setFrame:CGRectMake(self.bjsj.frame.origin.x, self.bjsj.frame.origin.y-64, self.bjsj.frame.size.width, 130)];
//        [self.dateTitleLabel setFrame:CGRectMake(self.dateTitleLabel.frame.origin.x, self.dateTitleLabel.frame.origin.y-64, self.dateTitleLabel.frame.size.width, self.dateTitleLabel.frame.size.height)];
        
    }
    
    //添加手势，点击输入框其他区域隐藏键盘
//    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
//    tapGr.cancelsTouchesInView =NO;
//    [self.view addGestureRecognizer:tapGr];
    
    
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];

    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *snum = [userDefaults objectForKey:@"schoolnum"];
    self.bjrs.text = [NSString stringWithFormat:@"%d",[snum intValue]];
    
    schoolnum = [snum intValue];
    
    [self loadData];
    NSLog(@"%@",self.bjsj);
}

//隐藏键盘
//-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
//    [self.bjsj resignFirstResponder];
//    [self.cqrs resignFirstResponder];
//    [self.bjrs2 resignFirstResponder];
//    [self.sjrs resignFirstResponder];
//    [self.cdrs resignFirstResponder];
//    if(self.view.frame.origin.y == -80){
//        [self moveView:80];
//    }
//}

- (void)loadData{
    [self showHudInView:self.view hint:@""];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.detailId forKey:@"dailyId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/SchoolDaily/findbyid.do" params:dic httpMethod:@"GET"];
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
        NSDictionary *data = [resultDict objectForKey:@"data"];
        if ([success boolValue]) {
            NSString *title = [data objectForKey:@"dailyTitle"];
            NSNumber *cqrs = [data objectForKey:@"attendanceNum"];
            NSNumber *bjrs = [data objectForKey:@"sickNum"];
            NSNumber *sjrs = [data objectForKey:@"casualNum"];
            NSNumber *cdrs = [data objectForKey:@"lateNum"];
            NSString *bjsj = [data objectForKey:@"dailyContent"];
            
            self.dateTitleLabel.text = title;
            self.sjrs.text = [NSString stringWithFormat:@"%@",sjrs];
            self.bjrs2.text = [NSString stringWithFormat:@"%@",bjrs];
            self.cdrs.text = [NSString stringWithFormat:@"%@",cdrs];
            self.cqrs.text = [NSString stringWithFormat:@"%@",cqrs];
            self.bjsj.text = bjsj;
            [self hideHud];
            
            
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
            [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
            NSDate *date =[dateFormat dateFromString:title];
            NSDate * now = [NSDate date];
            NSTimeInterval timeBetween = [now timeIntervalSinceDate:date];
            if (timeBetween > 60*60*24*7) {//7天之前
                [self.bjsj setUserInteractionEnabled:NO];
                [self.cqrs setUserInteractionEnabled:NO];
                [self.bjrs2 setUserInteractionEnabled:NO];
                [self.sjrs setUserInteractionEnabled:NO];
                [self.cdrs setUserInteractionEnabled:NO];
            }else{//7天之内可以修改
                //添加按钮
                UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(save)];
                self.navigationItem.rightBarButtonItem = rightBtn;
            }
            
        }else{
            [self hideHud];
            [self showHint:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (void)save{
//    [self viewTapped:nil];
    
    int num1 = [self.cqrs.text intValue];
    int num2 = [self.bjrs2.text intValue];
    int num3 = [self.sjrs.text intValue];
    int num4 = [self.cdrs.text intValue];
    
    if (schoolnum != (num1 + num2 + num3 + num4)) {
        [self showHint:@"总人数不等于班级人数"];
    }else{
        [self showHudInView:self.view hint:@""];
        
        if ([self.cqrs.text isEqualToString:@""]) {
            self.cqrs.text = @"0";
        }
        if ([self.bjrs2.text isEqualToString:@""]) {
            self.bjrs2.text = @"0";
        }
        if ([self.sjrs.text isEqualToString:@""]) {
            self.sjrs.text = @"0";
        }
        if ([self.cdrs.text isEqualToString:@""]) {
            self.cdrs.text = @"0";
        }
        
        
        
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[userDefaults objectForKey:@"userid"] forKey:@"userid"];
        [dic setValue:self.detailId forKey:@"dailyId"];
        [dic setValue:self.bjsj.text forKey:@"dailycontent"];
        [dic setValue:self.cqrs.text forKey:@"attnum"];
        [dic setValue:self.bjrs2.text forKey:@"sicknum"];
        [dic setValue:self.sjrs.text forKey:@"casualnum"];
        [dic setValue:self.cdrs.text forKey:@"latenum"];
        MKNetworkOperation *op = [engine operationWithPath:@"/classDaily/update.do" params:dic httpMethod:@"POST"];
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
                [self hideHud];
                UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                [self showHint:msg customView:imageview];
            }else{
                [self hideHud];
                [self showHint:msg];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [self hideHud];
            [self showHint:[err localizedDescription]];
        }];
        [engine enqueueOperation:op];
    }
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

//界面根据键盘的显示和隐藏上下移动
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
