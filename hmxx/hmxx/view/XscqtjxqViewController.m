//
//  XscqtjxqViewController.m
//  hmxx
//
//  Created by yons on 15-1-14.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XscqtjxqViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "SRRefreshView.h"
#import "TjxqTableViewCell.h"
#import "ExpansionTableViewCell.h"

@interface XscqtjxqViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    
    NSNumber *schoolNum;
    NSNumber *attendanceNum;
    NSNumber *sickNum;
    NSNumber *casualNum;
    NSNumber *lateNum;
    
    BOOL isOpen;
    NSIndexPath *selectedIndex;
}

@property (nonatomic, strong) SRRefreshView *slimeView;

@end

@implementation XscqtjxqViewController
@synthesize dataSource;
@synthesize mytableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
    }
    mytableView = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableView.dataSource = self;
    mytableView.delegate = self;
    if ([mytableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:mytableView];
    [mytableView addSubview:self.slimeView];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    //初始化数据
    [self loadData];
    
    isOpen = NO;
    
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
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
    
    if (self.info != nil) {
        NSString *title = [self.info objectForKey:@"title"];
        self.title = title;
        schoolNum = [self.info objectForKey:@"schoolNum"];//应到人数
        attendanceNum = [self.info objectForKey:@"attendanceNum"];//出勤人数
        sickNum = [self.info objectForKey:@"sickNum"];//病假人数
        casualNum = [self.info objectForKey:@"casualNum"];//事假人数
        lateNum = [self.info objectForKey:@"lateNum"];//迟到早退人数
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setValue:schoolid forKey:@"recordId"];
        [dic setValue:title forKey:@"date"];
        
        MKNetworkOperation *op = [engine operationWithPath:@"/schoolStudent/findAllList.do" params:dic httpMethod:@"GET"];
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
                NSArray *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    self.dataSource = [NSMutableArray arrayWithArray:data];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (isOpen) {
//        return [[self dataSource] count]+5;
//    }else{
//        return [[self dataSource] count]+5;
//    }
    
    return [self.dataSource count]*4+5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == selectedIndex.row && selectedIndex != nil) {
//        //如果是展开
//        if (isOpen == YES) {
//            static NSString *cellIdentifier = @"cell";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            if (!cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            }
//            cell.textLabel.text = @"学校统计2";
//            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }else{
//            static NSString *cellIdentifier = @"cell";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//            if (!cell) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//            }
//            cell.textLabel.text = @"学校统计3";
//            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
//    } else {
    
        if (indexPath.row == 0) {
            static NSString *cellIdentifier = @"cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text = @"学校统计";
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.row == 1){
            static NSString *cellIdentifier = @"tjxqcell";
            TjxqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TjxqTableViewCell" owner:self options:nil] lastObject];
            }
            cell.label1.text = [NSString stringWithFormat:@"应到人数:%@",schoolNum];
            cell.label2.text = [NSString stringWithFormat:@"出勤人数:%@",attendanceNum];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.row == 2){
            static NSString *cellIdentifier = @"tjxqcell";
            TjxqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TjxqTableViewCell" owner:self options:nil] lastObject];
            }
            cell.label1.text = [NSString stringWithFormat:@"病假人数:%@",sickNum];
            cell.label2.text = [NSString stringWithFormat:@"事假人数:%@",casualNum];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.row == 3){
            static NSString *cellIdentifier = @"tjxqcell";
            TjxqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TjxqTableViewCell" owner:self options:nil] lastObject];
            }
            cell.label1.text = [NSString stringWithFormat:@"迟到早退人数:%@",lateNum];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if (indexPath.row == 4){
            static NSString *cellIdentifier = @"cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text = @"班级详情";
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            
            if ((indexPath.row - 5) % 4 == 0) {
                static NSString *cellIdentifier = @"expancell";
                ExpansionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"ExpansionTableViewCell" owner:self options:nil] lastObject];
                }
                NSDictionary *data = [self.dataSource objectAtIndex:(indexPath.row-5)/4];
                NSString *class_name = [data objectForKey:@"class_name"];
                NSNumber *class_num = [data objectForKey:@"class_num"];
                NSNumber *attendance_num = [data objectForKey:@"attendance_num"];
                
                cell.label1.text = class_name;
                cell.label2.text = [NSString stringWithFormat:@"应到%d人",[class_num intValue]];
                cell.label3.text = [NSString stringWithFormat:@"实到%d人",[attendance_num intValue]];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else if((indexPath.row - 5) % 4 == 1){
                int i = (indexPath.row - 5) / 4;
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                
                static NSString *cellIdentifier = @"tjxqcell";
                TjxqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"TjxqTableViewCell" owner:self options:nil] lastObject];
                }
                NSNumber *attendance_num = [data objectForKey:@"attendance_num"];
                NSNumber *sick_num = [data objectForKey:@"sick_num"];
                cell.label1.text = [NSString stringWithFormat:@"出勤人数:%@",attendance_num];
                cell.label2.text = [NSString stringWithFormat:@"病假人数:%@",sick_num];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else if((indexPath.row - 5) % 4 == 2){
                int i = (indexPath.row - 5) / 4;
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                
                static NSString *cellIdentifier = @"tjxqcell";
                TjxqTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"TjxqTableViewCell" owner:self options:nil] lastObject];
                }
                NSNumber *casual_num = [data objectForKey:@"casual_num"];
                NSNumber *late_num = [data objectForKey:@"late_num"];
                cell.label1.text = [NSString stringWithFormat:@"事假人数:%@",casual_num];
                cell.label2.text = [NSString stringWithFormat:@"迟到早退人数:%@",late_num];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }else{
                int i = (indexPath.row - 5) / 4;
                NSDictionary *data = [self.dataSource objectAtIndex:i];
                
                static NSString *cellIdentifier = @"cell2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                NSString *daily_content = [data objectForKey:@"daily_content"];
                cell.textLabel.text = daily_content;
                [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                cell.textLabel.numberOfLines = 0;
                [cell.textLabel sizeToFit];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 4) {
        if ((indexPath.row - 5) % 4 == 0){
            return 50;
        }else{
            return 44;
        }
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
    
//    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
//    if (indexPath.row > 4) {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        if(selectedIndex == nil){
//            isOpen = YES;
//            selectedIndex = indexPath;
//            //        [self.dataSource addObject:@"aa"];
//            //        NSIndexPath *nextindex = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
//            //        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndex,nextindex,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//            
//            [self.dataSource insertObject:@"aaa" atIndex:indexPath.row];
//            indexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:0];
//            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        }
//        else{
//            isOpen = !isOpen;
//            bool hasSelectedOtherRow=![selectedIndex isEqual:indexPath];
//            NSIndexPath *temp = selectedIndex;
//            selectedIndex = nil;
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:temp] withRowAnimation:UITableViewRowAnimationAutomatic];
//            if(hasSelectedOtherRow){
//                selectedIndex = indexPath;
//                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            }
//        }
//        
//        
//        
//        
//        
//    }
    
    
//    [tableView beginUpdates];
    
//    if(selectedIndex == nil){
//        isOpen = YES;
//        selectedIndex = indexPath;
////        [self.dataSource addObject:@"aa"];
////        NSIndexPath *nextindex = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
////        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndex,nextindex,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
//        
//        [self.dataSource insertObject:@"aaa" atIndex:indexPath.row];
//        indexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:0];
//        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//    }
//    else{
//        isOpen = !isOpen;
//        bool hasSelectedOtherRow=![selectedIndex isEqual:indexPath];
//        NSIndexPath *temp = selectedIndex;
//        selectedIndex = nil;
//        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:temp] withRowAnimation:UITableViewRowAnimationAutomatic];
//        if(hasSelectedOtherRow){
//            selectedIndex = indexPath;
//            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//    }
//    [tableView endUpdates];
    
    
    
//    //将索引加到数组中
//    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
//    
//    
//    if (selectedIndex == nil) {
//        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
//        isOpen = YES;
//        NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row) inSection:0];
//        [self.dataSource insertObject:@"aaa" atIndex:path.row-5];
//        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//    }
//    
//    
//    //判断选中不同row状态时候
//    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
//    if (selectedIndex != nil && indexPath.row == selectedIndex.row) {
//        //将选中的和所有索引都加进数组中
//        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
//        isOpen = !isOpen;
//        
//    }else if (selectedIndex != nil && indexPath.row != selectedIndex.row) {
//        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
//        isOpen = YES;
//        NSIndexPath *path = [NSIndexPath indexPathForItem:(indexPath.row+1) inSection:0];
//        [self.dataSource insertObject:@"aaa" atIndex:path.row];
//        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
//    }
//    
//    //记下选中的索引
//    selectedIndex = indexPath;
//    
//    
//    //刷新
////    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//    NSLog(@"%@",indexPaths);
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