//
//  PurchaseReportViewController.m
//  hmxx
//
//  Created by yons on 15-1-24.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PurchaseReportViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "SRRefreshView.h"
#import "XscqtjxqViewController.h"
#import "MoreTableViewCell.h"
#import "ReportFirstTableViewCell.h"
#import "ReportSecondTableViewCell.h"
#import "ReportThirdTableViewCell.h"
#import "PurchaseTypeViewController.h"

@interface PurchaseReportViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    NSString *schoolid;
}
@property (nonatomic, strong) SRRefreshView *slimeView;
@end

@implementation PurchaseReportViewController
@synthesize mytableview;
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"reloadPurchaseReport"
                                               object:nil];
    
    
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-49);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64-49);
    }
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    //    mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    mytableview.dataSource = self;
    mytableview.delegate = self;
//    mytableView = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
//    mytableView.dataSource = self;
//    mytableView.delegate = self;
//    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [mytableview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [mytableview setLayoutMargins:UIEdgeInsetsZero];
//    }
    [mytableview addSubview:self.slimeView];
    [self.view addSubview:mytableview];
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    schoolid = [userdefault objectForKey:@"schoolid"];
    
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
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:self.year forKey:@"purchaseyear"];
    MKNetworkOperation *op = [engine operationWithPath:@"/purchasestatis/purchaseyearList.do" params:dic httpMethod:@"GET"];
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
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSMutableArray *arr = [NSMutableArray array];
                for (int i = 0; i < data.count; i++) {
                    NSMutableDictionary *datadic = [NSMutableDictionary dictionary];
                    [datadic setDictionary:[data objectAtIndex:i]];
                    [datadic setValue:@"1" forKey:@"level"];
                    [arr addObject:datadic];
                }
                self.dataSource = [NSMutableArray arrayWithArray:arr];
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

//加载详情
- (void)loadDetail:(NSString *)purchaseDate index:(NSInteger)index{
//    ReportFirstTableViewCell *cell = (ReportFirstTableViewCell *)[mytableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSMutableDictionary *firstDic = [self.dataSource objectAtIndex:index];//取得第一级的数据
    NSString *firstIsExtend = [firstDic objectForKey:@"isExtend"];
    if ([firstIsExtend isEqualToString:@"YES"]) {
//        cell.dataSource = [NSMutableArray array];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:schoolid forKey:@"schoolId"];
        [params setValue:purchaseDate forKey:@"purchaseDate"];
        MKNetworkOperation *op = [engine operationWithPath:@"/purchasestatis/purchaseList.do" params:params httpMethod:@"GET"];
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
                NSArray *dataArr = [resultDict objectForKey:@"data"];
                if (dataArr != nil) {
                    NSMutableArray *insertIndexPaths = [NSMutableArray array];
                    int j = 0;
                    for (int i = 0; i < dataArr.count; i++) {
                        NSDictionary *dic = [dataArr objectAtIndex:i];
                        NSString *purchaseDate = [dic objectForKey:@"purchaseDate"];//取得日期
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        NSDate *date = [dateFormatter dateFromString:purchaseDate];
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfMonth|NSCalendarUnitMonth|NSCalendarUnitWeekday fromDate:date];
                        NSInteger weekofMonth = [components weekOfMonth];
                        NSMutableDictionary *secondDic = [NSMutableDictionary dictionary];//第二级数据字典
                        NSString *week = [NSString stringWithFormat:@"%ld月第%ld周报表",(long)[components month],(long)weekofMonth];
                        [secondDic setValue:week forKey:@"weekofMonth"];
                        [secondDic setValue:@"2" forKey:@"level"];
                        NSNumber *totalPrice = [dic objectForKey:@"total_price"];//取得总价
                        NSMutableArray *secondArr = [firstDic objectForKey:@"secondArr"];//第一级下的第二级数组
                        if (secondArr == nil) {
                            secondArr = [NSMutableArray array];
                        }
                        NSMutableDictionary *secondLastDic = [secondArr lastObject];//取得第一级下第二级数组的最后一个
                        NSString *s = [secondLastDic objectForKey:@"weekofMonth"];
                        
                        if ([s isEqualToString:week]) {
                            NSDictionary *tempSecondDic = [self.dataSource objectAtIndex:index +j];//取得上一个第二级的数据
                            NSMutableArray *tempThirdArr = [tempSecondDic objectForKey:@"thirdArr"];//取得第二级下的第三级数组
                            if (tempThirdArr == nil) {
                                tempThirdArr = [NSMutableArray array];
                            }
                            [tempThirdArr addObject:[dataArr objectAtIndex:i]];//取得第三级的日数据插入到第三级的数组中
                            [tempSecondDic setValue:tempThirdArr forKey:@"thirdArr"];//将第三级的数组设置到第二级数据字典中
                            NSNumber *price = [tempSecondDic objectForKey:@"totalPrice"];
                            NSNumber *allPrice = [NSNumber numberWithDouble:[totalPrice doubleValue] + [price doubleValue]];
                            [tempSecondDic setValue:allPrice forKey:@"totalPrice"];
//                            [self.dataSource replaceObjectAtIndex:index +j withObject:datadic];
                        }else{
                            NSMutableArray *thirdArr = [NSMutableArray array];//第三级的数组应该放在第二级中
                            [thirdArr addObject:[dataArr objectAtIndex:i]];
                            [secondDic setValue:totalPrice forKey:@"totalPrice"];
                            [secondDic setValue:thirdArr forKey:@"thirdArr"];//将第三级数组设置到第二级字典中
                            [self.dataSource insertObject:secondDic atIndex:index+j+1];
                            [secondArr addObject:secondDic];//将第二级的数据插入到第一级下的第二级数组中
                            [firstDic setObject:secondArr forKey:@"secondArr"];//将第一级下的第二级数组设置到第一级的字典中
//                            [self.dataSource replaceObjectAtIndex:index withObject:firstDic];//替换数据源中的第一级数据
                            NSIndexPath *nextindex = [NSIndexPath indexPathForRow:index+j+1 inSection:0];
                            [insertIndexPaths addObject:nextindex];
                            j++;
                        }
                    }
                    [mytableview beginUpdates];
                    [mytableview insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                    [mytableview endUpdates];
                }
                [HUD hide:YES];
            }else{
                [HUD hide:YES];
                [self alertMsg:msg];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [HUD hide:YES];
            [self alertMsg:@"连接服务器失败"];
            NSString *isExtend = [firstDic objectForKey:@"isExtend"];
            if ([isExtend isEqualToString:@"YES"]) {
                [firstDic setValue:@"NO" forKey:@"isExtend"];
            }
        }];
        [engine enqueueOperation:op];
    }else{
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        int k = 0;
        NSMutableArray *secondArr = [firstDic objectForKey:@"secondArr"];
        for (int i = 0; i < secondArr.count; i++) {
            NSDictionary *secondDic = [secondArr objectAtIndex:i];
            NSString *secondIsExtend = [secondDic objectForKey:@"isExtend"];
            if ([secondIsExtend isEqualToString:@"YES"]) {
                NSArray *thirdArr = [secondDic objectForKey:@"thirdArr"];
                for (int j = 0; j< thirdArr.count; j++) {
                    [self.dataSource removeObjectAtIndex:index+1];
                    NSIndexPath *nextindex = [NSIndexPath indexPathForRow:index+k+1 inSection:0];
                    [insertIndexPaths addObject:nextindex];
                    k++;
                }
            }
            [self.dataSource removeObjectAtIndex:index+1];
            NSIndexPath *nextindex = [NSIndexPath indexPathForRow:index+k+1 inSection:0];
            [insertIndexPaths addObject:nextindex];
            k++;
        }
        [secondArr removeAllObjects];
        [mytableview beginUpdates];
        [mytableview deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [mytableview endUpdates];
    }
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *level = [data objectForKey:@"level"];
    if ([level isEqualToString:@"1"]) {
        static NSString *cellIdentifier = @"reportfirst";
        ReportFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ReportFirstTableViewCell" owner:self options:nil] lastObject];
        }
        NSString *purchaseyear = [data objectForKey:@"purchaseyear"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        NSDate *date = [dateFormatter dateFromString:purchaseyear];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"MM月报表"];
        NSString *date2 = [dateFormatter2 stringFromDate:date];
        NSNumber *total_price = [data objectForKey:@"total_price"];
        cell.titleLabel.text = date2;
        cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[total_price doubleValue]];
        return cell;
    }else if([level isEqualToString:@"2"]){
        static NSString *cellIdentifier = @"reportsecond";
        ReportSecondTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ReportSecondTableViewCell" owner:self options:nil] lastObject];
        }
        NSString *purchaseDate = [data objectForKey:@"weekofMonth"];
        NSNumber *totalPrice = [data objectForKey:@"totalPrice"];
        cell.titleLabel.text = purchaseDate;
        cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[totalPrice doubleValue]];
        return cell;
    }else if([level isEqualToString:@"3"]){
        static NSString *cellIdentifier = @"reportthird";
        ReportThirdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ReportThirdTableViewCell" owner:self options:nil] lastObject];
        }
        NSString *purchaseDate = [data objectForKey:@"purchaseDate"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date = [dateFormatter dateFromString:purchaseDate];
        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setDateFormat:@"MM.dd"];
        
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:date];
        NSInteger weekday = [components weekday];
        
        NSString *weekdayStr ;
        switch (weekday) {
            case 1:
                weekdayStr = @"(周日)";
                break;
            case 2:
                weekdayStr = @"(周一)";
                break;
            case 3:
                weekdayStr = @"(周二)";
                break;
            case 4:
                weekdayStr = @"(周三)";
                break;
            case 5:
                weekdayStr = @"(周四)";
                break;
            case 6:
                weekdayStr = @"(周五)";
                break;
            case 7:
                weekdayStr = @"(周六)";
                break;
            default:
                break;
        }
        
        NSString *date2 = [dateFormatter2 stringFromDate:date];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",date2,weekdayStr];
        
        
        NSNumber *total_price = [data objectForKey:@"total_price"];
        cell.moneyLabel.text = [NSString stringWithFormat:@"￥%.2f",[total_price doubleValue]];
        return cell;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *level = [data objectForKey:@"level"];
    if ([level isEqualToString:@"1"]) {
        NSString *isExtend = [data objectForKey:@"isExtend"];
        if ([isExtend isEqualToString:@"YES"]) {
            [data setValue:@"NO" forKey:@"isExtend"];
        }else{
            [data setValue:@"YES" forKey:@"isExtend"];
        }
        [self loadDetail:[data objectForKey:@"purchaseyear"] index:indexPath.row];
    }else if([level isEqualToString:@"2"]){
        NSString *isExtend = [data objectForKey:@"isExtend"];
        if ([isExtend isEqualToString:@"YES"]) {
            [data setValue:@"NO" forKey:@"isExtend"];
            NSArray *thirdArr = [data objectForKey:@"thirdArr"];
            NSMutableArray *insertIndexPaths = [NSMutableArray array];
            for (int i = 0; i < thirdArr.count; i++) {
                [self.dataSource removeObjectAtIndex:indexPath.row+1];
                NSIndexPath *nextindex = [NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0];
                [insertIndexPaths addObject:nextindex];
            }
            [mytableview beginUpdates];
            [mytableview deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [mytableview endUpdates];
        }else{
            [data setValue:@"YES" forKey:@"isExtend"];
            NSArray *thirdArr = [data objectForKey:@"thirdArr"];
            NSMutableArray *insertIndexPaths = [NSMutableArray array];
            for (int i = 0; i < thirdArr.count; i++) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[thirdArr objectAtIndex:i]];
                [data setValue:@"3" forKey:@"level"];
                [self.dataSource insertObject:data atIndex:indexPath.row+i+1];
                NSIndexPath *nextindex = [NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0];
                [insertIndexPaths addObject:nextindex];
            }
            [mytableview beginUpdates];
            [mytableview insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            [mytableview endUpdates];
        }
        
    }else{
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        NSDictionary *info = [self.dataSource objectAtIndex:indexPath.row];
        NSString *purchaseDate = [info objectForKey:@"purchaseDate"];
        PurchaseTypeViewController *vc = [[PurchaseTypeViewController alloc] init];
        vc.purchaseDate = purchaseDate;
        vc.title = purchaseDate;
        vc.isShow = NO;
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
    [HUD show:YES];
    [self loadData];
    [_slimeView endRefresh];
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
