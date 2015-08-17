//
//  GgxqViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GgxqViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "ContentCell.h"
#import "PinglunTableViewCell.h"
#import "SRRefreshView.h"
#import "MoreTableViewCell.h"
#import "MJRefresh.h"

@interface GgxqViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    
    UIActivityIndicatorView *tempactivity;
}

@end

@implementation GgxqViewController
@synthesize mytableview;

- (id)init{
    self = [super init];
    if(self){
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.mytableview setFrame:CGRectMake(0, 0, self.mytableview.frame.size.width,self.mytableview.frame.size.height+64)];
    }
    
//    [self initTextView];

    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
   
    // 添加下拉刷新控件
    self.mytableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //初始化数据
        [self loadDataPingLun];
    }];
    self.mytableview.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadDataPingLunMore];
    }];
    
    self.dataSource = [NSMutableArray array];
    
    [self.mytableview.header beginRefreshing];
}



//加载评论
- (void)loadDataPingLun{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.tnid forKey:@"recordId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    
    
    if (self.type == 2) {//学校公告
        [dic setValue:[NSNumber numberWithInt:4] forKey:@"type"];
    }else if(self.type == 3){//班级公告
        [dic setValue:[NSNumber numberWithInt:3] forKey:@"type"];
    }
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Comment/findPageList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        [self.mytableview.header endRefreshing];
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource removeAllObjects];
                [self.dataSource addObjectsFromArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.mytableview reloadData];
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self.mytableview.header endRefreshing];
        
    }];
    [engine enqueueOperation:op];
}

- (void)loadDataPingLunMore{
    
    if ([page intValue]< [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:self.tnid forKey:@"recordId"];
        [dic setValue:page forKey:@"page"];
        [dic setValue:rows forKey:@"rows"];
        [dic setValue:[NSNumber numberWithInt:self.type] forKey:@"type"];
        if (self.type == 2) {//学校公告
            [dic setValue:[NSNumber numberWithInt:4] forKey:@"type"];
        }else if(self.type == 3){//班级公告
            [dic setValue:[NSNumber numberWithInt:3] forKey:@"type"];
        }
        MKNetworkOperation *op = [engine operationWithPath:@"/Comment/findPageList.do" params:dic httpMethod:@"GET"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
            //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
            [self.mytableview.footer endRefreshing];
            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
            NSString *msg = [resultDict objectForKey:@"msg"];
            if ([success boolValue]) {
                NSDictionary *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    NSArray *arr = [data objectForKey:@"rows"];
                    [self.dataSource addObjectsFromArray:arr];
                    NSNumber *total = [data objectForKey:@"total"];
                    if ([total intValue] % [rows intValue] == 0) {
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                    }else{
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                    }
                }
                if ([tempactivity isAnimating]) {
                    [tempactivity stopAnimating];
                }
                [self.mytableview reloadData];
            }else{
                [self alertMsg:msg];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [self.mytableview.footer endRefreshing];
            [self alertMsg:@"连接服务器失败"];
        }];
        [engine enqueueOperation:op];
    }
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"pingluncell";
    PinglunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PinglunTableViewCell" owner:self options:nil] lastObject];
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *commentContent = [data objectForKey:@"commentContent"];
    NSString *fileid = [data objectForKey:@"fileid"];
    NSString *userName = [data objectForKey:@"userName"];
    NSString *commentDate = [data objectForKey:@"commentDate"];
    
    cell.namelabel.text = userName;
    [cell.namelabel setTextColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
    cell.datelabel.text = commentDate;
    
    
    
    //评论内容 高度自适应
    cell.commentlabel.text = commentContent;
    cell.commentlabel.numberOfLines = 0;
    cell.commentlabel.lineBreakMode = NSLineBreakByCharWrapping;
    [cell.commentlabel sizeToFit];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [commentContent sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-59, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    [cell.commentlabel setFrame:CGRectMake(cell.commentlabel.frame.origin.x, cell.commentlabel.frame.origin.y, cell.commentlabel.frame.size.width, size.height)];
    
    
    if ([Utils isBlankString:fileid]) {
        [cell.img setImage:[UIImage imageNamed:@"nopicture2.png"]];
    }else{
        //            [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"nopicture2.png"]];
        [cell.img setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture2.png"]];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    // 列寬
    CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width-59;
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:14];
    // 該行要顯示的內容
    NSString *content = [[self.dataSource objectAtIndex:row] objectForKey:@"commentContent"];
    // 計算出顯示完內容需要的最小尺寸
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    return size.height+60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
