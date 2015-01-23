//
//  MainViewController.m
//  hmjz
//
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MainViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "ShezhiViewController.h"
#import "BbspViewController.h"
#import "JYSlideSegmentController.h"
#import "KcbViewController.h"
#import "GrdaViewController.h"
#import "MyTabbarController.h"
#import "MyTabbarController2.h"
#import "MyTabbarController3.h"
#import "XscqtjViewController.h"
#import "PurchaseViewController.h"
#import "ScheduleViewController.h"
#import "CollectionViewController.h"
#import "MyTabbarController4.h"

@interface MainViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate>{
    MKNetworkEngine *engine;
    NSArray *kcbarr;//课程表
    NSArray *sparr;//食谱
    MBProgressHUD *HUD;
    
    SMPageControl *spacePageControl;
    UIScrollView *mainScrollView;
}

@property (strong, nonatomic)NSDate *lastPlaySoundDate;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    self.navigationController.delegate = self;
    
    [self.navigationController setNavigationBarHidden:YES];
    // 禁用 iOS7 返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
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
    
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(grdaAction:)];
    [self.userimg addGestureRecognizer:singleTap1];
    self.userimg.layer.cornerRadius = self.userimg.frame.size.height/2;
    self.userimg.layer.masksToBounds = YES;
    [self.userimg setContentMode:UIViewContentModeScaleAspectFill];
    [self.userimg setClipsToBounds:YES];
    self.userimg.layer.borderColor = [UIColor colorWithRed:183/255.0 green:178/255.0 blue:160/255.0 alpha:1].CGColor;
    self.userimg.layer.borderWidth = 0.5f;
    self.userimg.layer.shadowOffset = CGSizeMake(4.0, 4.0);
    self.userimg.layer.shadowOpacity = 0.5;
    self.userimg.layer.shadowRadius = 2.0;
    
    
    //初始化网络引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];

    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.delegate = self;
    [mainScrollView setPagingEnabled:YES];
    mainScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:mainScrollView];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    [self loadData];//加载信息
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
     //得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
     //根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    spacePageControl.currentPage = currentPage;
}

//加载信息
- (void)loadData{
    
    [HUD show:YES];
    //根据用户id获取学校
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:userid forKey:@"userId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolUser/findschoolbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSString *result = [operation responseString];
        NSLog(@"%@",result);
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil && data.count > 0) {
                NSDictionary *info = [data objectAtIndex:0];
//                NSString *username = [info objectForKey:@"schoolName"];
                NSString *userid = [info objectForKey:@"userId"];
                NSString *schoolid = [info objectForKey:@"schoolId"];
                NSNumber *schoolnum = [info objectForKey:@"schoolnum"];
                [userDefaults setObject:schoolid forKey:@"schoolid"];
                [userDefaults setObject:schoolnum forKey:@"schoolnum"];
                [self getUserInfo:userid schoolid:schoolid];
                [self loadsp:schoolid];//食谱
                [self loadZxsjb:schoolid];//作息时间表
            }else{
                [HUD hide:YES];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
    }];
    [engine enqueueOperation:op];
}

//根据用户id和学校id获取管理员信息包括菜单
-(void)getUserInfo:(NSString *)userid schoolid:(NSString *)schoolid {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userId"];
    [dic setValue:schoolid forKey:@"schoolId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolUser/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSString *result = [operation responseString];
        
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSLog(@"%@",resultDict);
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:data forKey:@"user"];
                
//                NSString *schoolName = [data objectForKey:@"schoolName"];
                NSString *userName = [data objectForKey:@"userName"];
//                NSString *uId = [data objectForKey:@"uId"];
                NSString *fileid = [data objectForKey:@"fileid"];
                self.username.text = userName;
                //设置头像
                if ([Utils isBlankString:fileid]) {
                    [self.userimg setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
                }else{
                    [self.userimg setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
                }
                
                //获取菜单
                NSArray *controlList = [data objectForKey:@"controlList"];
                self.menus = [[NSMutableArray alloc] init];
                for (int i = 0 ; i < [controlList count]; i++) {
                    NSDictionary *menu = [controlList objectAtIndex:i];
                    NSEnumerator * enumerator = [menu keyEnumerator];
                    id object;
                    //遍历输出
                    while(object = [enumerator nextObject])
                    {
                        id objectValue = [menu objectForKey:object];
                        if(objectValue != nil)
                        {
                            if ([objectValue intValue] == 0) {
                                [self.menus addObject:object];
                            }
                        }
                    }
                }
                
                [self setButtons];
                
                [HUD hide:YES];
            }else{
                [HUD hide:YES];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
    }];
    [engine enqueueOperation:op];
}

-(void)setButtons{
    float height = [UIScreen mainScreen].bounds.size.height;
    float width = [UIScreen mainScreen].bounds.size.width;
    [mainScrollView setFrame:CGRectMake(0, 170, width, height-170)];
    
    int i = 0;
    for (NSString *menuStr in self.menus) {
        CGRect btnr;
        switch (i) {
            case 0:
                btnr = CGRectMake(10, 10, 90, 90);
                break;
            case 1:
                btnr = CGRectMake(width/2-45, 10, 90, 90);
                break;
            case 2:
                btnr = CGRectMake(width-100, 10, 90, 90);
                break;
            case 3:
                btnr = CGRectMake(10, 135, 90, 90);
                break;
            case 4:
                btnr = CGRectMake(width/2-45, 135, 90, 90);
                break;
            case 5:
                btnr = CGRectMake(width-100, 135, 90, 90);
                break;
            case 6:
                if (height <= 480) {
                    btnr = CGRectMake(width+10, 10, 90, 90);
                }else{
                    btnr = CGRectMake(10, 260, 90, 90);
                }
                break;
            case 7:
                if (height <= 480) {
                    btnr = CGRectMake(width+width/2-45, 10, 90, 90);
                }else{
                    btnr = CGRectMake(width/2-45, 260, 90, 90);
                }
                break;
            case 8:
                if (height <= 480) {
                    btnr = CGRectMake(width*2-100, 10, 90, 90);
                }else{
                    btnr = CGRectMake(width-100, 260, 90, 90);
                }
                break;
            default:
                btnr = CGRectMake(0, 0, 0, 0);
                break;
        }
        
        
        if ([menuStr isEqualToString:@"myschool"]) {
            i++;
            UIButton *btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn4 setFrame:btnr];
            [btn4 setBackgroundImage:[UIImage imageNamed:@"ic_index_003.png"] forState:UIControlStateNormal];;
            [btn4 addTarget:self action:@selector(wdxx) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label4 = [[UILabel alloc] init];
            if (btn4.frame.origin.x != 0) {
                [label4 setFrame:CGRectMake(btn4.frame.origin.x, btn4.frame.origin.y+95, 90, 20)];
                label4.text = @"我的学校";
                label4.textAlignment = NSTextAlignmentCenter;
                [label4 setFont:[UIFont systemFontOfSize:15]];
                [label4 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn4];
                [mainScrollView addSubview:label4];
            }
        }else if([menuStr isEqualToString:@"schoolmanage"]){
            i++;
            UIButton *btn2 = [[UIButton alloc] init];
            [btn2 setFrame:btnr];
            [btn2 setBackgroundImage:[UIImage imageNamed:@"ic_index_002.png"] forState:UIControlStateNormal];
            [btn2 addTarget:self action:@selector(ywgl) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label2 = [[UILabel alloc] init];
            if (btn2.frame.origin.x != 0) {
                [label2 setFrame:CGRectMake(btn2.frame.origin.x, btn2.frame.origin.y+95, 90, 20)];
                label2.text = @"园务管理";
                label2.textAlignment = NSTextAlignmentCenter;
                [label2 setFont:[UIFont systemFontOfSize:15]];
                [label2 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn2];
                [mainScrollView addSubview:label2];
            }
        }else if([menuStr isEqualToString:@"personalmanage"]){
            i++;
            UIButton *btn1 = [[UIButton alloc] init];
            [btn1 setFrame:btnr];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"ic_index_007.png"] forState:UIControlStateNormal];
            [btn1 addTarget:self action:@selector(grrz) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label1 = [[UILabel alloc] init];
            if (btn1.frame.origin.x != 0) {
                [label1 setFrame:CGRectMake(btn1.frame.origin.x, btn1.frame.origin.y+95, 90, 20)];
                label1.text = @"个人日志";
                label1.textAlignment = NSTextAlignmentCenter;
                [label1 setFont:[UIFont systemFontOfSize:15]];
                [label1 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn1];
                [mainScrollView addSubview:label1];
            }
        }else if([menuStr isEqualToString:@"schoolcook"]){
            i++;
            UIButton *btn1 = [[UIButton alloc] init];
            [btn1 setFrame:btnr];
            [btn1 setBackgroundImage:[UIImage imageNamed:@"ic_index_004.png"] forState:UIControlStateNormal];
            [btn1 addTarget:self action:@selector(xsspAction:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label1 = [[UILabel alloc] init];
            if (btn1.frame.origin.x != 0) {
                [label1 setFrame:CGRectMake(btn1.frame.origin.x, btn1.frame.origin.y+95, 90, 20)];
                label1.text = @"食谱管理";
                label1.textAlignment = NSTextAlignmentCenter;
                [label1 setFont:[UIFont systemFontOfSize:15]];
                [label1 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn1];
                [mainScrollView addSubview:label1];
            }
        }else if([menuStr isEqualToString:@"schoolaudit"]){
            i++;
            UIButton *btn3 = [[UIButton alloc] init];
            [btn3 setFrame:btnr];
            [btn3 setBackgroundImage:[UIImage imageNamed:@"ic_index_006.png"] forState:UIControlStateNormal];
            [btn3 addTarget:self action:@selector(xxsh) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label3 = [[UILabel alloc] init];
            if (btn3.frame.origin.x != 0) {
                [label3 setFrame:CGRectMake(btn3.frame.origin.x, btn3.frame.origin.y+95, 90, 20)];
                label3.text = @"学校审核";
                label3.textAlignment = NSTextAlignmentCenter;
                [label3 setFont:[UIFont systemFontOfSize:15]];
                [label3 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn3];
                [mainScrollView addSubview:label3];
            }
        }else if([menuStr isEqualToString:@"schoolatime"]){
            i++;
            UIButton *btn5 = [[UIButton alloc] init];
            [btn5 setFrame:btnr];
            [btn5 setBackgroundImage:[UIImage imageNamed:@"ic_index_007.png"] forState:UIControlStateNormal];
            [btn5 addTarget:self action:@selector(zxsjbAction:) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label5 = [[UILabel alloc] init];
            if (btn5.frame.origin.x != 0) {
                [label5 setFrame:CGRectMake(btn5.frame.origin.x, btn5.frame.origin.y+95, 90, 20)];
                label5.text = @"作息时间表";
                label5.textAlignment = NSTextAlignmentCenter;
                [label5 setFont:[UIFont systemFontOfSize:15]];
                [label5 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn5];
                [mainScrollView addSubview:label5];
            }
        }else if([menuStr isEqualToString:@"statistical"]){
            i++;
            UIButton *btn6 = [[UIButton alloc] init];
            [btn6 setFrame:btnr];
            [btn6 setBackgroundImage:[UIImage imageNamed:@"ic_item_chuqin.png"] forState:UIControlStateNormal];
            [btn6 addTarget:self action:@selector(xscqtj) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label6 = [[UILabel alloc] init];
            if (btn6.frame.origin.x != 0) {
                [label6 setFrame:CGRectMake(btn6.frame.origin.x, btn6.frame.origin.y+95, 90, 20)];
                label6.text = @"学生出勤统计";
                label6.textAlignment = NSTextAlignmentCenter;
                [label6 setFont:[UIFont systemFontOfSize:15]];
                [label6 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn6];
                [mainScrollView addSubview:label6];
            }
        }else if([menuStr isEqualToString:@"staff_1"]){
            i++;
            UIButton *btn6 = [[UIButton alloc] init];
            [btn6 setFrame:btnr];
            [btn6 setBackgroundImage:[UIImage imageNamed:@"ic_index_007.png"] forState:UIControlStateNormal];
            [btn6 addTarget:self action:@selector(aa) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label6 = [[UILabel alloc] init];
            if (btn6.frame.origin.x != 0) {
                [label6 setFrame:CGRectMake(btn6.frame.origin.x, btn6.frame.origin.y+95, 90, 20)];
                label6.text = @"学校健康管理";
                label6.textAlignment = NSTextAlignmentCenter;
                [label6 setFont:[UIFont systemFontOfSize:15]];
                [label6 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn6];
                [mainScrollView addSubview:label6];
            }
        }else if([menuStr isEqualToString:@"schoolpurchase"]){
            i++;
            UIButton *btn6 = [[UIButton alloc] init];
            [btn6 setFrame:btnr];
            [btn6 setBackgroundImage:[UIImage imageNamed:@"ic_index_007.png"] forState:UIControlStateNormal];
            [btn6 addTarget:self action:@selector(cmbb) forControlEvents:UIControlEventTouchUpInside];
            UILabel *label6 = [[UILabel alloc] init];
            if (btn6.frame.origin.x != 0) {
                [label6 setFrame:CGRectMake(btn6.frame.origin.x, btn6.frame.origin.y+95, 90, 20)];
                label6.text = @"采买报表";
                label6.textAlignment = NSTextAlignmentCenter;
                [label6 setFont:[UIFont systemFontOfSize:15]];
                [label6 setBackgroundColor:[UIColor clearColor]];
                [mainScrollView addSubview:btn6];
                [mainScrollView addSubview:label6];
            }
        }else{
            continue;
        }
        
    }
    if (i > 6) {
        if (height <= 480) {
            [mainScrollView setContentSize:CGSizeMake(width*2, height-170)];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
                spacePageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0.0, height-30, width, 10)];
            }else{
                spacePageControl = [[SMPageControl alloc] initWithFrame:CGRectMake(0.0, height-50, width, 10)];
            }
            
            [spacePageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
            [spacePageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
            spacePageControl.numberOfPages = 2;
            spacePageControl.indicatorMargin = 10.0f;
            spacePageControl.indicatorDiameter = 10.0f;
            spacePageControl.userInteractionEnabled = NO;
            [self.view addSubview:spacePageControl];
        }else{
            [mainScrollView setContentSize:CGSizeMake(width, height-170)];
        }
    }else{
        [mainScrollView setContentSize:CGSizeMake(width, height-170)];
    }
}

//加载食谱
- (void)loadsp:(NSString *)schoolid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/SchoolCook/findScookList.do" params:dic httpMethod:@"GET"];
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
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                sparr = data;
            }
        }else{
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

//学生食谱
- (IBAction)xsspAction:(UIButton *)sender {
    
    NSMutableArray *vcs = [NSMutableArray array];
    
    for (int i = 0 ; i < [sparr count]; i++) {
        BbspViewController *vc = [[BbspViewController alloc] init];
        NSArray *data = [sparr objectAtIndex:i];
        vc.dataSource = data;
        NSDictionary *info = [data objectAtIndex:0];
        NSString *date = [info objectForKey:@"occurDate"];
        if (date.length > 5) {
            //            vc.title = [[info objectForKey:@"occurDate"] substringFromIndex:5];
            
            switch (i) {
                case 0:
                    vc.title = @"周一";
                    break;
                case 1:
                    vc.title = @"周二";
                    break;
                case 2:
                    vc.title = @"周三";
                    break;
                case 3:
                    vc.title = @"周四";
                    break;
                case 4:
                    vc.title = @"周五";
                    break;
                default:
                    break;
            }
            
        }
        [vcs addObject:vc];
    }
    
    if (vcs.count > 0) {
        JYSlideSegmentController *slideSegmentController = [[JYSlideSegmentController alloc] initWithViewControllers:vcs];
        
        slideSegmentController.title = @"学生食谱";
        slideSegmentController.indicatorInsets = UIEdgeInsetsMake(0, 8, 8, 8);
        slideSegmentController.indicator.backgroundColor = [UIColor greenColor];
        
        //设置背景图片
        UIImage *image = [UIImage imageNamed:@"ic_sp_001.png"];
        slideSegmentController.view.layer.contents = (id)image.CGImage;
        
        [self.navigationController setNavigationBarHidden:NO];
        [self.navigationController pushViewController:slideSegmentController animated:YES];
    }else{
        //提示没有信息
        [self alertMsg:@"暂时没有食谱信息，请稍后再试"];
    }
}


//加载作息时间表
- (void)loadZxsjb:(NSString *)schoolid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/SchoolTimes/findAllList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //            NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                kcbarr = data;
            }
        }else{
            
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
    }];
    [engine enqueueOperation:op];
}

//作息时间表
- (IBAction)zxsjbAction:(UIButton *)sender {
    KcbViewController *vc = [[KcbViewController alloc] init];
    vc.title = @"作息时间表";
    vc.dataSource = kcbarr;
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController pushViewController:vc animated:YES];
    
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
//隐藏导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([viewController isKindOfClass:[MainViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}


//设置
- (IBAction)setup:(UIButton *)sender {
    ShezhiViewController *sz = [[ShezhiViewController alloc] init];
    [self.navigationController pushViewController:sz animated:YES];
}
//个人中心
- (void)grdaAction:(UITapGestureRecognizer *)sender{
    GrdaViewController *vc = [[GrdaViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}
//我的学校
-(void)wdxx{
    MyTabbarController *tabBarCtl = [[MyTabbarController alloc] init];
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//园务管理
-(void)ywgl{
    MyTabbarController2 *tabBarCtl = [[MyTabbarController2 alloc] init];
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//学校审核
-(void)xxsh{
    MyTabbarController3 *tabBarCtl = [[MyTabbarController3 alloc] init];
    [self.navigationController pushViewController:tabBarCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//学生出勤统计
-(void)xscqtj{
    XscqtjViewController *vc = [[XscqtjViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//采买报表
-(void)cmbb{
    PurchaseViewController *vc = [[PurchaseViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//个人日志
-(void)grrz{
    MyTabbarController4 *vc = [[MyTabbarController4 alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)aa{
    CollectionViewController *vc = [[CollectionViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

//返回到该页面调用
- (void)viewDidAppear:(BOOL)animated{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *backflag = [userDefaults objectForKey:@"backflag"];
//    if ([@"1" isEqualToString:backflag]) {//选择完班级和宝宝 返回重新加载
//        [userDefaults removeObjectForKey:@"backflag"];
//        [self loadData];//设置学生信息
//        [self loadYezx];//加载育儿资讯分类
//        [self loadBbsp];//加载食谱
//        [self loadKcb];//加载课程表
//    }
//    NSString *loginflag = [userDefaults objectForKey:@"loginflag"];//如果是登陆则删除标识符
//    if ([@"1" isEqualToString:loginflag]) {
//        [userDefaults removeObjectForKey:@"loginflag"];
//    }
    NSString *updateImgFlag = [userDefaults objectForKey:@"updateImgFlag"];//如果是修改头像返回则重新加载信息
    if ([@"1" isEqualToString:updateImgFlag]) {
        [userDefaults removeObjectForKey:@"updateImgFlag"];
        [self loadData];
    }
    [super viewDidAppear:animated];
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


- (void)dealloc{
    
}

#pragma mark - private
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

@end
