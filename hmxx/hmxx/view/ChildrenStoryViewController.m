//
//  ChildrenStoryViewController.m
//  hmjz
//
//  Created by yons on 15-8-11.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "ChildrenStoryViewController.h"
#import "MKNetworkKit.h"
#import "ChildrenStoryTableViewCell.h"
#import "PlayTableViewCell.h"
#import "MJRefresh.h"
#import "Utils.h"
#import "CustomMoviePlayerViewController.h"
#import "KrVideoPlayerController.h"

@interface ChildrenStoryViewController (){
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    NSMutableArray *segDataSource;
    NSMutableArray *dataSource;
    
    NSIndexPath *selectedIndex;
    BOOL flag;
}
@property BOOL  show;
@property (nonatomic, strong) KrVideoPlayerController  *videoController;
@end

@implementation ChildrenStoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.myseg removeAllSegments];
    self.title = @"益智乐园";
    
    self.show = NO;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    dataSource = [NSMutableArray array];
    segDataSource = [NSMutableArray array];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.mytableview.tableFooterView = v;
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    [self loadSeg];
    
    // 添加下拉刷新控件
    self.mytableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //初始化数据
        [self loadData];
    }];
    self.mytableview.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMore];
    }];
    
    
}

//加载数据
- (void)loadSeg{
    
    
    MKNetworkOperation *op = [engine operationWithPath:@"/puzzle/puzzletypeList.do" params:nil httpMethod:@"GET"];
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
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                for(int i = 0 ; i < arr.count ;i ++){
                    NSDictionary *info = [arr objectAtIndex:i];
                    NSString *typename = [info objectForKey:@"typename"];
//                    NSString *typeid = [info objectForKey:@"id"];
                    [segDataSource addObject:info];
                    [self.myseg insertSegmentWithTitle:typename atIndex:i animated:YES];

                }
                [self.myseg setSelectedSegmentIndex:0];
                [self.myseg addTarget:self action:@selector(segChanged:) forControlEvents:UIControlEventValueChanged];
                [self.mytableview.header beginRefreshing];
            }
        }else{
            [self showHint:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self.mytableview.header endRefreshing];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}


//加载数据
- (void)loadData{
    
    flag = NO;
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSDictionary *info = [segDataSource objectAtIndex:self.myseg.selectedSegmentIndex];
    NSString *typeid = [info objectForKey:@"id"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:typeid forKey:@"typeid"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/puzzle/puzzleList.do" params:dic httpMethod:@"GET"];
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
            [self.mytableview.header endRefreshing];
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                dataSource = [NSMutableArray arrayWithArray:arr];
                NSNumber *total = [data objectForKey:@"total"];
                
                
                if ([total intValue] % [rows intValue] == 0) {
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                }else{
                    totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                }
                
                
                
                [self.mytableview reloadData];
            }
        }else{
            [self.mytableview.header endRefreshing];
            [self showHint:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self.mytableview.header endRefreshing];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (void)loadMore{
    if ([page intValue] < [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
        NSDictionary *info = [segDataSource objectAtIndex:self.myseg.selectedSegmentIndex];
        NSString *typeid = [info objectForKey:@"id"];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:typeid forKey:@"typeid"];
        [dic setValue:page forKey:@"page"];
        [dic setValue:rows forKey:@"rows"];
        MKNetworkOperation *op = [engine operationWithPath:@"/puzzle/puzzleList.do" params:dic httpMethod:@"GET"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
            //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
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
                [self.mytableview.footer endRefreshing];
                NSDictionary *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    NSArray *arr = [data objectForKey:@"rows"];
                    [dataSource addObjectsFromArray:arr];
                    NSNumber *total = [data objectForKey:@"total"];
                    if ([total intValue] % [rows intValue] == 0) {
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue]];
                    }else{
                        totalpage = [NSNumber numberWithInt:[total intValue] / [rows intValue] + 1];
                    }
                    [self.mytableview reloadData];
                }
            }else{
                [self.mytableview.footer endRefreshing];
                [self showHint:msg];
                
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [self.mytableview.footer endRefreshing];
            [self showHint:[err localizedDescription]];
        }];
        [engine enqueueOperation:op];
    }
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
    NSString *cellStatus = [info objectForKey:@"cellStatus"];
    if (cellStatus != nil && [cellStatus isEqualToString:@"play"]) {
        PlayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PlayTableViewCell" owner:self options:nil] lastObject];
        }
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
        cell.shareLabel.userInteractionEnabled = YES;
        cell.shareLabel.tag = indexPath.row;
        [cell.shareLabel addGestureRecognizer:tap1];
        
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play:)];
        cell.playLabel.userInteractionEnabled = YES;
        cell.playLabel.tag = indexPath.row;
        [cell.playLabel addGestureRecognizer:tap2];
        
        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detail:)];
        cell.detailLabel.userInteractionEnabled = YES;
        cell.detailLabel.tag = indexPath.row;
        [cell.detailLabel addGestureRecognizer:tap3];
        
        return cell;
    }else{
        ChildrenStoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChildrenStoryTableViewCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ChildrenStoryTableViewCell" owner:self options:nil] lastObject];
        }
        
        NSNumber *type = [info objectForKey:@"type"];
        NSString *title = [info objectForKey:@"title"];
        //    NSString *path = [info objectForKey:@"path"];
        //    NSString *content = [info objectForKey:@"content"];
        cell.label1.text = title;
        if ([type intValue] == 0) {
            [cell.image setImage:[UIImage imageNamed:@"mp3"]];
        }else if ([type intValue] == 1) {
            [cell.image setImage:[UIImage imageNamed:@"mp4"]];
        }
        return cell;
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
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:[PlayTableViewCell class]]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if (indexPath.row == selectedIndex.row) {
            if (flag) {
                flag = NO;
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:indexPath.section];
                [dataSource removeObjectAtIndex:selectedIndex.row+1];
                [tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                flag = YES;
                selectedIndex = indexPath;
                NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:indexPath.section];
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[dataSource objectAtIndex:selectedIndex.row]];
                [info setObject:@"play" forKey:@"cellStatus"];
                [dataSource insertObject:info atIndex:selectedIndex.row+1];
                [tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }else{
            if (flag) {
                flag = NO;
                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:indexPath.section];
                [dataSource removeObjectAtIndex:selectedIndex.row+1];
                [tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                if (indexPath.row > selectedIndex.row) {
                    indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                }
            }
            flag = YES;
            selectedIndex = indexPath;
            NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:selectedIndex.row+1 inSection:indexPath.section];
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[dataSource objectAtIndex:selectedIndex.row]];
            [info setObject:@"play" forKey:@"cellStatus"];
            [dataSource insertObject:info atIndex:selectedIndex.row+1];
            [tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    
}
/**
 *  分享
 *
 *  @param gesture
 */
-(void)share:(UITapGestureRecognizer *)gesture{
    NSDictionary *info = [dataSource objectAtIndex:gesture.view.tag - 1];
    NSString *title = [info objectForKey:@"title"];
    NSString *content = [info objectForKey:@"content"];
    NSString *path = [info objectForKey:@"path"];
    
    NSString *textToShare = [NSString stringWithFormat:@"名称:%@",title];
    NSURL *urlToShare = [NSURL URLWithString:path];
    NSMutableArray *activityItems =[NSMutableArray array];
    [activityItems addObject:textToShare];
    [activityItems addObject:[NSString stringWithFormat:@"详情:%@",content]];
    [activityItems addObject:[NSString stringWithFormat:@"链接:%@",urlToShare]];
    [activityItems addObject:[NSString stringWithFormat:@"(官网:www.hmjxt.com)"]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems  applicationActivities:nil];
    [self presentViewController:activityController  animated:YES completion:nil];
}

/**
 *  播放
 *
 *  @param gesture
 */
-(void)play:(UITapGestureRecognizer *)gesture{
    NSDictionary *info = [dataSource objectAtIndex:gesture.view.tag - 1];
    NSString *path = [info objectForKey:@"path"];
//    CustomMoviePlayerViewController *moviePlayer = [[CustomMoviePlayerViewController alloc] init];
//    moviePlayer.moviePlayer.scalingMode=MPMovieScalingModeAspectFit;//窗口模式设置
//    moviePlayer.moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
//    //将视频地址传过去
//    moviePlayer.movieURL = [NSURL URLWithString:path];
//    //然后播放就OK了
//    [moviePlayer readyPlayer];
//    [self presentViewController:moviePlayer animated:YES completion:^{
//    }];
    
    NSURL *url = [NSURL URLWithString:path];
    [self addVideoPlayerWithURL:url];
    
//    MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:playerViewController];
//    //-- add to view---
//    [self presentViewController:playerViewController animated:YES completion:^{
//    }];
//    
//    //---play movie---
//    MPMoviePlayerController *player = [playerViewController moviePlayer];
//    [player play];
    
    
}

- (void)addVideoPlayerWithURL:(NSURL *)url{
    if (!self.videoController) {
        self.videoController = [[KrVideoPlayerController alloc] initWithFrame:self.view.frame];
        __weak typeof(self)weakSelf = self;
        [self.videoController setDimissCompleteBlock:^{
            weakSelf.videoController = nil;
            [weakSelf toolbarHidden:NO];
            weakSelf.show = NO;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController setWillBackOrientationPortrait:^{
            [weakSelf toolbarHidden:NO];
            weakSelf.show = YES;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController setWillChangeToFullscreenMode:^{
            [weakSelf toolbarHidden:YES];
            weakSelf.show = YES;
            [weakSelf setNeedsStatusBarAppearanceUpdate];
        }];
        [self.videoController showInWindow];
        self.show = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.videoController.contentURL = url;
}

- (void)toolbarHidden:(BOOL)Bool{
//    self.navigationController.navigationBar.hidden = Bool;
//    self.tabBarController.tabBar.hidden = Bool;
//    [[UIApplication sharedApplication] setStatusBarHidden:Bool];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return self.show; // 返回NO表示要显示，返回YES将hiden
}

//- (void) movieFinishedCallback:(NSNotification*) aNotification {
//    MPMoviePlayerViewController *playerViewController = [aNotification object];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:playerViewController];
//    [[playerViewController moviePlayer] stop];
//    [playerViewController dismissMoviePlayerViewControllerAnimated];
//}

/**
 *  详情
 *
 *  @param gesture
 */
-(void)detail:(UITapGestureRecognizer *)gesture{
    NSDictionary *info = [dataSource objectAtIndex:gesture.view.tag - 1];
//    NSString *title = [info objectForKey:@"title"];
    NSString *content = [info objectForKey:@"content"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"详情" message:content delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)segChanged:(UISegmentedControl *)seg{
    [self.mytableview.header beginRefreshing];
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
