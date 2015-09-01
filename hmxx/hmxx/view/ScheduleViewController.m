//
//  ScheduleViewController.m
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ScheduleViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "SRRefreshView.h"
#import "DailyTableViewCell.h"
#import "ScheduleDetailViewController.h"
#import "MoreTableViewCell.h"

@interface ScheduleViewController ()<SRRefreshDelegate>{
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    NSString *userid;
    NSString *schoolid;
    NSNumber *roletype;
    UIActivityIndicatorView *tempactivity;
}
@property (nonatomic, strong) SRRefreshView *slimeView;
@end

@implementation ScheduleViewController
@synthesize dataSource;
@synthesize mytableview;
@synthesize type;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"reloadDaily"
                                               object:nil];
    
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-49-64);
    }
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    mytableview.dataSource = self;
    mytableview.delegate = self;
    [self.view addSubview:mytableview];
    [mytableview addSubview:self.slimeView];
    
    [self showHudInView:self.view hint:@""];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    userid = [userdefault objectForKey:@"userid"];
    schoolid = [userdefault objectForKey:@"schoolid"];
    NSDictionary *userdata = [userdefault objectForKey:@"user"];
    roletype = [userdata objectForKey:@"roletype"];
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
    
    NSString *path ;
    if ([roletype intValue] == 2) {//学校管理员  不传userid  查看所有日志
        [dic setValue:@"" forKey:@"userid"];
        [dic setValue:schoolid forKey:@"schoolId"];
        path = @"/busdaily/findschoolList.do";
    }else if([roletype intValue] == 3){//非教师用户 传userid 查看个人日志
        [dic setValue:userid forKey:@"userid"];
        path = @"/busdaily/findPageList.do";
    }else{
        [dic setValue:@"" forKey:@"userid"];
    }
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:type forKey:@"dailyType"];
    //    [dic setValue:classId forKey:@"classId"];
    MKNetworkOperation *op = [engine operationWithPath:path params:dic httpMethod:@"GET"];
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
                self.dataSource = [NSMutableArray arrayWithArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                [mytableview reloadData];
            }
            [self hideHud];
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
    NSString *path ;
    if ([roletype intValue] == 2) {//学校管理员  不传userid  查看所有日志
        [dic setValue:@"" forKey:@"userid"];
        [dic setValue:schoolid forKey:@"schoolId"];
        path = @"/busdaily/findschoolList.do";
    }else if([roletype intValue] == 3){//非教师用户 传userid 查看个人日志
        [dic setValue:userid forKey:@"userid"];
        path = @"/busdaily/findPageList.do";
    }else{
        [dic setValue:@"" forKey:@"userid"];
    }
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    [dic setValue:type forKey:@"dailyType"];
    MKNetworkOperation *op = [engine operationWithPath:path params:dic httpMethod:@"GET"];
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
        MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MoreTableViewCell" owner:self options:nil] lastObject];
        }
        cell.msg.text = @"显示下10条";
        return cell;
        
    }else{
        static NSString *cellIdentifier = @"DailyCell";
        DailyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DailyTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *title = [info objectForKey:@"title"];
        NSString *createDate = [info objectForKey:@"createDate"];
        NSString *creator = [info objectForKey:@"creator"];
        cell.titleLabel.text = title;
        cell.createrLabel.text = creator;
        cell.dateLabel.text = createDate;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.dataSource count] == indexPath.row) {
        return 55;
    }else{
        return 54;
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
            MoreTableViewCell *cell = (MoreTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.msg.text = @"加载中...";
            [cell.activity startAnimating];
            tempactivity = cell.activity;
            [self loadMore];
        }
        
    }else{
        if (indexPath.row < [self.dataSource count]) {
            NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
            NSString *detailId = [info objectForKey:@"id"];
            ScheduleDetailViewController *vc = [[ScheduleDetailViewController alloc] init];
            vc.detailId = detailId;
            vc.type = type;
            vc.roletype = roletype;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
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
    [self showHudInView:self.view hint:@""];
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
