//
//  CollectionViewController.m
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionCell.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "SRRefreshView.h"
#import "UIImageView+AFNetworking.h"
#import "CwjDetailViewController.h"
#import "SVPullToRefresh.h"

@interface CollectionViewController ()<MBProgressHUDDelegate,SRRefreshDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    
    NSString *userid;
    
    NSString *fileName;
    
    NSIndexPath *fromIndex;
    NSIndexPath *toIndex;
}
@end

@implementation CollectionViewController
@synthesize mycollectionview;
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    fileName = @"collectionUser";
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData2:)
                                                 name:@"reloadCwj"
                                               object:nil];
    
    [mycollectionview registerClass:[CollectionCell class] forCellWithReuseIdentifier:@"CollectionCell"];
    mycollectionview.alwaysBounceVertical = YES;
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userid = [userDefaults objectForKey:@"userid"];
    
    dataSource = [[NSMutableArray alloc] init];
    
    __weak CollectionViewController *weakSelf = self;
    
    [mycollectionview addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];

    //初始化数据
    [mycollectionview triggerPullToRefresh];
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData:YES indexPath:nil];
    });
}


-(void)loadData2:(NSNotification*) notification{
    NSIndexPath *indexpath = [notification object];
    NSLog(@"%d",indexpath.row);
    [self loadData:NO indexPath:indexpath];
}

//加载数据
- (void)loadData:(BOOL)flag indexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.examinetype forKey:@"examinetype"];
    [dic setValue:self.examinedate forKey:@"examinedate"];
    [dic setValue:self.classid forKey:@"classid"];
    [dic setValue:userid forKey:@"userid"];
    MKNetworkOperation *op = [engine operationWithPath:@"/examine/findPageList.do" params:dic httpMethod:@"GET"];
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
                NSArray *arr = [data objectForKey:@"list"];

                NSDictionary *map = [data objectForKey:@"examineMap"];
                NSNumber *okcount = [map objectForKey:@"okcount"];
                NSNumber *qqcount = [map objectForKey:@"qqcount"];
                NSNumber *yccount = [map objectForKey:@"yccount"];
                
                self.label1.text = [NSString stringWithFormat:@"正常%d人",[okcount intValue]];
                self.label2.text = [NSString stringWithFormat:@"异常%d人",[yccount intValue]];
                self.label3.text = [NSString stringWithFormat:@"缺勤%d人",[qqcount intValue]];

                NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
                NSString *documentDirectory =[documentPaths objectAtIndex:0];
                NSString *filePath=[documentDirectory stringByAppendingPathComponent:fileName];
                NSMutableDictionary *localDic = [self readFromLocal:filePath];
                [dataSource removeAllObjects];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                for (int i = 0; i < arr.count; i++) {
                    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:[arr objectAtIndex:i]];
                    NSString *tempuserid = [info objectForKey:@"studentid"];
                    if (localDic) {
                        NSNumber *localsort = [localDic objectForKey:tempuserid];
                        if (localsort) {//如果存在本地数据
                            [info setValue:localsort forKey:@"localsort"];
                        }else{//如果没有本地数据
                            NSNumber *sort = [info objectForKey:@"sort"];
                            [info setValue:sort forKey:@"localsort"];
                        }
                    }else{//如果没有本地数据
                        NSNumber *sort = [info objectForKey:@"sort"];
                        [info setValue:sort forKey:@"localsort"];
                    }
                    [dic setValue:[info objectForKey:@"localsort"]  forKey:tempuserid];
                    [self.dataSource addObject:info];
                }
                [self saveToLocal:dic];
                //排序
                [self arrSort:self.dataSource];
            }
            NSLog(@"表格刷新");
            [mycollectionview.pullToRefreshView stopAnimating];
            [mycollectionview reloadData];
            if (flag) {
                //[self alertMsg:@"刷新成功,长按头像拖动排序"];
            }else{
                //[mycollectionview scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
            }
        }else{
            [mycollectionview.pullToRefreshView stopAnimating];
            [self alertMsg:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [mycollectionview.pullToRefreshView stopAnimating];
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource count];
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CollectionCell";
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
    NSString *fileid = [info objectForKey:@"fileid"];
    NSString *situationtype = [info objectForKey:@"situationtype"];
    if (situationtype) {
        [cell.label1 setHidden:NO];
        if ([situationtype isEqualToString:@"1"]) {
            [cell.label1 setText:[NSString stringWithFormat:@"正常"]];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
        }else if ([situationtype isEqualToString:@"2"]) {
            [cell.label1 setText:[NSString stringWithFormat:@"缺勤"]];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:130/255.0 green:115/255.0 blue:8/255.0 alpha:1]];
        }else if ([situationtype isEqualToString:@"3"]) {
            [cell.label1 setText:[NSString stringWithFormat:@"异常"]];
            [cell.label1 setBackgroundColor:[UIColor colorWithRed:76/255.0 green:28/255.0 blue:12/255.0 alpha:1]];
        }else{
            [cell.label1 setHidden:YES];
        }
    }else{
        [cell.label1 setHidden:YES];
    }
    
    NSString *studentName = [info objectForKey:@"studentName"];
    cell.username.text = studentName;
    
    
    if ([Utils isBlankString:fileid]) {
        [cell.myimageview setImage:[UIImage imageNamed:@"nopicture2.png"]];
    }else{
        [cell.myimageview setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture2.png"]];
    }
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90, 110);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
    CwjDetailViewController *cwj = [[CwjDetailViewController alloc] init];
    cwj.title = self.tabBarController.title;
    cwj.info = info;
    cwj.indexpath = indexPath;
    cwj.title = [NSString stringWithFormat:@"%@详情",self.title];
    [self.navigationController pushViewController:cwj animated:YES];
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    NSDictionary *info = [dataSource objectAtIndex:fromIndexPath.item];
    
    [dataSource removeObjectAtIndex:fromIndexPath.item];
    [dataSource insertObject:info atIndex:toIndexPath.item];
    
    fromIndex = fromIndexPath;
    toIndex = toIndexPath;
    NSLog(@"fromIndexPath:%d toIndexPath%d",fromIndexPath.row , toIndexPath.row);
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath{
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    fromIndex = nil;
    toIndex = nil;
    NSLog(@"will begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did begin drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"will end drag");
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did end drag");
    NSLog(@"fromIndexPath:%d toIndexPath%d",fromIndex.row , toIndex.row);
    NSLog(@"%d",indexPath.row);
    if (fromIndex && toIndex && fromIndex.row != toIndex.row) {
        NSLog(@"开始排序%@",[NSDate date]);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        for (int i = 0 ; i < dataSource.count; i++) {
            NSDictionary *info = [dataSource objectAtIndex:i];
            NSString *studentName = [info objectForKey:@"studentName"];
            NSString *tempuserid = [info objectForKey:@"studentid"];
            [dic setValue:[NSNumber numberWithInt:i+1]  forKey:tempuserid];
            NSLog(@"%@ 序号 %d",studentName,i+1);
        }
        [self saveToLocal:dic];
        NSLog(@"排序结束%@",[NSDate date]);
    }
    
}

#pragma mark - private
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
    [hud hide:YES afterDelay:1.5];
}

-(void)saveToLocal:(NSMutableDictionary *)dic{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);
    NSString *documentDirectory =[documentPaths objectAtIndex:0];
//    NSLog(@"%@",documentDirectory);
    NSString *filePath=[documentDirectory stringByAppendingPathComponent:fileName];
//    NSData* xmlData = [@"testdata" dataUsingEncoding:NSUTF8StringEncoding];
//    BOOL flag = [xmlData writeToFile:fileName atomically:YES];
//    NSLog(@"%@",flag ? @"成功" : @"失败");
    
//    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"balance", @"key",
//                            @"remaining balance", @"label",
//                            @"45", @"value",
//                            @"USD", @"currencyCode",nil];
    
    
    NSMutableDictionary *localDic = [self readFromLocal:filePath];
    if (localDic) {
        NSLog(@"添加了%d条数据",[dic count]);
        [localDic setValuesForKeysWithDictionary:dic];
    }else{
        NSLog(@"初始化 添加了%d条数据",[dic count]);
        localDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:localDic forKey:@"userlist"];
    [archiver finishEncoding];
    BOOL flag = [data writeToFile:filePath atomically:YES];
    NSLog(@"保存本地:%@ : %d",flag ? @"成功" : @"失败",[localDic count]);
//    NSData *data=[NSData dataWithContentsOfFile:fileName options:0 error:NULL];
//    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
}

-(NSMutableDictionary *)readFromLocal:(NSString *)filename{
    NSData *data=[NSData dataWithContentsOfFile:filename options:0 error:NULL];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSMutableDictionary *myDictionary = [unarchiver decodeObjectForKey:@"userlist"];
        [unarchiver finishDecoding];
        NSLog(@"读取本地数据成功:%d",[myDictionary count]);
        return myDictionary;
    }else{
        NSLog(@"读取本地数据失败");
        return nil;
    }
}

-(void)arrSort:(NSArray *)beforeArray{
    NSComparator cmptr = ^(id obj1, id obj2){
        NSNumber *sort1 = [obj1 objectForKey:@"localsort"];
        NSNumber *sort2 = [obj2 objectForKey:@"localsort"];
        if ([sort1 integerValue] > [sort2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([sort1 integerValue] < [sort2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    //排序前
    NSLog(@"排序前:");
    for (NSDictionary *info in beforeArray) {
        NSNumber *localsort = [info objectForKey:@"localsort"];
        NSLog(@"%d",[localsort intValue]);
    }
    //第一种排序
    NSArray *array = [beforeArray sortedArrayUsingComparator:cmptr];
    NSLog(@"排序后:");
    for (NSDictionary *info in array) {
        NSNumber *localsort = [info objectForKey:@"localsort"];
        NSLog(@"%d",[localsort intValue]);
    }
    dataSource = [NSMutableArray arrayWithArray:array];
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
