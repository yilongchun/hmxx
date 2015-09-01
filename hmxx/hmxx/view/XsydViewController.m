//
//  XsydViewController.m
//  hmxx
//
//  Created by yons on 15-2-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XsydViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "SRRefreshView.h"
#import "MoreTableViewCell.h"
#import "XsydDetailViewController.h"
#import "XsydTableViewCell.h"

@interface XsydViewController ()<SRRefreshDelegate>{
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    UIActivityIndicatorView *tempactivity;
    NSString *schoolid;
}
@property (nonatomic, strong) SRRefreshView *slimeView;

@end

@implementation XsydViewController
@synthesize mytableview;
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    schoolid = [userDefaults objectForKey:@"schoolid"];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
//    CGRect cg;
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
//        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-49);
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }else{
//        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-49);
//    }
//    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
//    mytableview.dataSource = self;
//    mytableview.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    
    [mytableview addSubview:self.slimeView];
    [self.view addSubview:mytableview];
    
    CGRect rect = self.slimeView.frame;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    [self.slimeView setFrame:rect];
    
    
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
    [self showHudInView:self.view hint:@""];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:schoolid forKey:@"schoolId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/schooltransfer/findPageList.do" params:dic httpMethod:@"GET"];
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
            [self hideHud];
            [mytableview reloadData];
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
}

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:schoolid forKey:@"schoolId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/schooltransfer/findPageList.do" params:dic httpMethod:@"GET"];
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
            [self showHint:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self showHint:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
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
        static NSString *cellIdentifier = @"xsydcell";
        XsydTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"XsydTableViewCell" owner:self options:nil] lastObject];
        }

        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *occurdate = [info objectForKey:@"occurdate"];
        NSNumber *studentnum = [info objectForKey:@"studentnum"];
        NSNumber *classnum = [info objectForKey:@"classnum"];
        cell.datelabel.text = occurdate;
        cell.numlabel1.text = [NSString stringWithFormat:@"%d",[studentnum intValue]];
        cell.numlabel2.text = [NSString stringWithFormat:@"%d",[classnum intValue]];
        
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
        XsydDetailViewController *vc = [[XsydDetailViewController alloc] init];
        NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
        NSString *occurdate = [info objectForKey:@"occurdate"];
        vc.occurdate = occurdate;
        [self.navigationController pushViewController:vc animated:YES];
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
