//
//  CwjViewController.m
//  hmjs
//
//  Created by yons on 15-2-5.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "CwjViewController.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "CwjTableViewCell.h"
#import "Utils.h"
#import "SRRefreshView.h"
#import "MoreTableViewCell.h"
#import "CwjClassViewController.h"

@interface CwjViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    UIActivityIndicatorView *tempactivity;
}
@property (nonatomic, strong) SRRefreshView *slimeView;

@end

@implementation CwjViewController
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"reloadCwjVc"
                                               object:nil];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    [mytableview addSubview:self.slimeView];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    //初始化数据
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private

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
    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:[userDefaults objectForKey:@"schoolid"] forKey:@"schoolId"];
    [dic setValue:self.examinetype forKey:@"examinetype"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/examine/schoolpageList.do" params:dic httpMethod:@"GET"];
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
            }
            [HUD hide:YES];
            [mytableview reloadData];
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

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:[userDefaults objectForKey:@"schoolid"] forKey:@"schoolId"];
    [dic setValue:self.examinetype forKey:@"examinetype"];
    MKNetworkOperation *op = [engine operationWithPath:@"/examine/schoolpageList.do" params:dic httpMethod:@"GET"];
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
            [mytableview reloadData];
        }else{
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self alertMsg:@"连接服务器失败"];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (page != totalpage && [self.dataSource count] != 0) {
        return [[self dataSource] count] + 1;
    }else{
        return [[self dataSource] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource count] == indexPath.row) {
        static NSString *cellIdentifier = @"morecell";
        MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MoreTableViewCell" owner:self options:nil] lastObject];
        }
        cell.msg.text = @"显示下10条";
        return cell;
        
    }else{
        static NSString *cellIdentifier = @"cwjcell";
        CwjTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CwjTableViewCell" owner:self options:nil] lastObject];
        }
        
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *examinedate = [info objectForKey:@"examinedate"];
        NSNumber *acount = [info objectForKey:@"acount"];
        NSNumber *bcount = [info objectForKey:@"bcount"];
        NSNumber *ccount = [info objectForKey:@"ccount"];
        NSNumber *dcount = [info objectForKey:@"dcount"];
        
        cell.dateLabel.text = examinedate;
        cell.anum.text = [NSString stringWithFormat:@"%d",[acount intValue]];
        cell.bnum.text = [NSString stringWithFormat:@"%d",[bcount intValue]];
        cell.cnum.text = [NSString stringWithFormat:@"%d",[ccount intValue]];
        cell.dnum.text = [NSString stringWithFormat:@"%d",[dcount intValue]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
        return 55;
    }else{
        return 44;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataSource count] == indexPath.row) {
        if (page == totalpage) {
            
        }else{
            MoreTableViewCell *cell = (MoreTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.msg.text = @"加载中...";
            [cell.activity startAnimating];
            tempactivity = cell.activity;
            [self loadMore];
        }
        
    }else{
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *examinedate = [info objectForKey:@"examinedate"];
        CwjClassViewController *vc1 = [[CwjClassViewController alloc] init];
        vc1.examinetype = self.examinetype;
        vc1.examinedate = examinedate;
        if ([self.examinetype isEqualToString:@"1"]) {
            vc1.title = [NSString stringWithFormat:@"%@ 晨检",examinedate];
        }else if ([self.examinetype isEqualToString:@"2"]) {
            vc1.title = [NSString stringWithFormat:@"%@ 午检",examinedate];
        }
        [self.navigationController pushViewController:vc1 animated:YES];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
