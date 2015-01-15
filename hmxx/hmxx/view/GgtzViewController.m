//
//  GgtzViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GgtzViewController.h"
#import "GgtzTableViewCell.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "GgxqViewController.h"
#import "SRRefreshView.h"
#import "UIImageView+AFNetworking.h"


@interface GgtzViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    
    
    NSString *schoolid;
}
    
@property (nonatomic, strong) SRRefreshView         *slimeView;

@end

@implementation GgtzViewController
@synthesize dataSource;
@synthesize mytableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"reloadGggl"
                                               object:nil];

    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-50-64);
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-50-64);
    }
    mytableView = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [mytableView setSeparatorColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
//    if ([mytableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [mytableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([mytableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [mytableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    mytableView.dataSource = self;
    mytableView.delegate = self;
    [self.view addSubview:mytableView];
    
    [mytableView addSubview:self.slimeView];
    

    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    schoolid = [userDefaults objectForKey:@"schoolid"];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    
    //初始化数据
    [self loadData];
    
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

//加载数据
- (void)loadData{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
//    [dic setValue:classId forKey:@"classId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolNotice/findallList.do" params:dic httpMethod:@"GET"];
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
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.mytableView reloadData];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接失败"];
    }];
    [engine enqueueOperation:op];
}

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolNotice/findallList.do" params:dic httpMethod:@"GET"];
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
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                [self.dataSource addObjectsFromArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [self.mytableView reloadData];
            }
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接失败"];
    }];
    [engine enqueueOperation:op];
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
    [hud hide:YES afterDelay:1.5];
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


#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (page != totalpage && [self.dataSource count] != 0) {
        return [[self dataSource] count] + 1;
    }else{
        return [[self dataSource] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataSource count] == indexPath.row) {
        static NSString *cellIdentifier = @"morecell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.text = @"点击加载更多";
        }
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;

    }else{
        static NSString *cellIdentifier = @"ggtzcell";
        GgtzTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"GgtzTableViewCell" owner:self options:nil] lastObject];
        }
        
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *tntitle = [info objectForKey:@"tntitle"];
        NSString *tncontent = [info objectForKey:@"tncontent"];
        NSNumber *noticecount = [info objectForKey:@"noticecount"];
        NSString *tncreatedate = [info objectForKey:@"tncreatedate"];
        NSString *noticename = [info objectForKey:@"noticename"];
        NSString *fileid = [info objectForKey:@"fileid"];
        cell.gtitle.text = tntitle;
        cell.gdispcription.text = tncontent;
        cell.gdispcription.numberOfLines = 2;// 不可少Label属性之一
        cell.gdispcription.lineBreakMode = NSLineBreakByCharWrapping;// 不可少Label属性之二
        //[cell.gdispcription sizeToFit];
        cell.gpinglun.text = [NSString stringWithFormat:@"评论(%@)",noticecount];
        cell.gdate.text = tncreatedate;
        cell.gsource.text = [NSString stringWithFormat:@"来自:%@",noticename];
        if ([Utils isBlankString:fileid]) {
            [cell.imageview setImage:[UIImage imageNamed:@"nopicture.png"]];
        }else{
            [cell.imageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        }
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
            return 44;
    }else{
        return 100;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
        if (page == totalpage) {
            
        }else{
            [HUD show:YES];
            [self loadMore];
        }
        
    }else{
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *tnid = [info objectForKey:@"tnid"];
        GgxqViewController *ggxq = [[GgxqViewController alloc]init];
        ggxq.title = @"公告详情";
        ggxq.tnid = tnid;
        [self.navigationController pushViewController:ggxq animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadData];
    [_slimeView endRefresh];
}




@end
