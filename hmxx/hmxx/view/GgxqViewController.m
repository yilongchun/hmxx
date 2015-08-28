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
#import "ContentCell.h"
#import "PinglunTableViewCell.h"
#import "IQKeyboardManager.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "UIViewController+HUD.h"
#import "MLPhotoBrowserViewController.h"

@interface GgxqViewController (){
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    int tntype;
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

//点击其他位置 隐藏键盘
-(void)hideKeyboard{
    [textView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.mytableview setFrame:CGRectMake(0, 0, self.mytableview.frame.size.width,self.mytableview.frame.size.height+64)];
    }
    
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
        [self loadData];
    }];
    self.mytableview.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadDataPingLunMore];
    }];
    
    self.dataSource = [NSMutableArray array];
    
    [self.mytableview.header beginRefreshing];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)loadData{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:userid forKey:@"userId"];
    [dic setValue:self.tnid forKey:@"tnid"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Notice/findbyid.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.mytableview.header endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *resultDict= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *success = [resultDict objectForKey:@"success"];
            NSString *msg = [resultDict objectForKey:@"msg"];
            //        NSString *code = [resultDict objectForKey:@"code"];
            if ([success boolValue]) {
                NSDictionary *data = [resultDict objectForKey:@"data"];
                if (data != nil) {
                    self.dataSource = [NSMutableArray arrayWithObject:data];
                    NSNumber *type = [data objectForKey:@"tntype"];
                    tntype = [type intValue];
                    [self loadDataPingLun];
                }
            }else{
                [self showHint:msg];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.mytableview.header endRefreshing];
        [self showHint:@"连接失败"];
    }];
}

//加载评论
- (void)loadDataPingLun{
    
    page = [NSNumber numberWithInt:1];
    rows = [NSNumber numberWithInt:10];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.tnid forKey:@"recordId"];
    [dic setValue:page forKey:@"page"];
    [dic setValue:rows forKey:@"rows"];
    
    if (tntype == 2) {//学校公告
        [dic setValue:[NSNumber numberWithInt:4] forKey:@"type"];
    }else if(tntype == 3){//班级公告
        [dic setValue:[NSNumber numberWithInt:3] forKey:@"type"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@/Comment/findPageList.do",HOST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.mytableview.header endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *resultDict= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *success = [resultDict objectForKey:@"success"];
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
                    [self.mytableview reloadData];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.mytableview.header endRefreshing];
        [self showHint:@"连接失败"];
    }];
}

- (void)loadDataPingLunMore{
    if ([page intValue]< [totalpage intValue]) {
        page = [NSNumber numberWithInt:[page intValue] +1];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:self.tnid forKey:@"recordId"];
        [dic setValue:page forKey:@"page"];
        [dic setValue:rows forKey:@"rows"];
        if (tntype == 2) {//学校公告
            [dic setValue:[NSNumber numberWithInt:4] forKey:@"type"];
        }else if(tntype == 3){//班级公告
            [dic setValue:[NSNumber numberWithInt:3] forKey:@"type"];
        }
        
        NSString *urlString = [NSString stringWithFormat:@"http://%@/Comment/findPageList.do",HOST];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager GET:urlString parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", operation.responseString);
            [self.mytableview.footer endRefreshing];
            NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
            NSError *error;
            NSDictionary *resultDict= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }else{
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
                    [self.mytableview reloadData];
                }else{
                    [self showHint:msg];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"发生错误！%@",error);
            [self.mytableview.footer endRefreshing];
            [self showHint:@"连接失败"];
        }];
    }else{
        [self.mytableview.footer endRefreshing];
    }
}

/**
 *  点击图片查看大图
 */
-(void)showPic:(UITapGestureRecognizer *)recognizer{
    // 图片游览器
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc] init];
    // 缩放动画
    photoBrowser.status = UIViewAnimationAnimationStatusFade;
    // 可以删除
    photoBrowser.editing = NO;
    // 数据源/delegate
    //    photoBrowser.delegate = self;
    // 同样支持数据源/DataSource
    //                    photoBrowser.dataSource = self;
    
    NSMutableArray *imgDataSource = [NSMutableArray array];
    
    
    NSDictionary *data = [self.dataSource objectAtIndex:0];
    NSArray *picList = [data objectForKey:@"picList"];
    
    for (int i = 0; i < picList.count; i++) {
        MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc] init];
        photo.photoURL = [NSURL URLWithString:[[picList objectAtIndex:i] objectForKey:@"fileId"]];
        [imgDataSource addObject:photo];
    }
    
    photoBrowser.photos = imgDataSource;
    int index = (int)recognizer.view.tag;
    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath row] == 0) {
        static NSString *cellIdentifier = @"contentcell";
        ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ContentCell" owner:self options:nil] lastObject];
        }
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        
        NSString *title = [data objectForKey:@"tntitle"];
        NSString *date = [data objectForKey:@"tnmoddate"];
        NSString *content = [data objectForKey:@"tncontent"];
        NSString *noticename = [data objectForKey:@"noticename"];
        cell.contentTitle.text = title;
        cell.contentDate.text = date;
        cell.content.text = content;
        cell.creater.text = noticename;
        //    cell.content.text = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        cell.content.numberOfLines = 0;
        cell.content.lineBreakMode = NSLineBreakByCharWrapping;
        [cell.content sizeToFit];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        [cell.content setFrame:CGRectMake(cell.content.frame.origin.x, cell.content.frame.origin.y, cell.content.frame.size.width, size.height)];
        
        NSArray *picList = [data objectForKey:@"picList"];
        if ([picList count] > 0) {
            
            CGFloat x = 0;
            CGFloat y = cell.content.frame.origin.y + 10 + cell.content.frame.size.height;
            for (int i = 0 ; i < [picList count]; i++) {
                NSDictionary *picDic = [picList objectAtIndex:i];
                if ((i % 3 == 0) && i != 0) {
                    y += 105;
                }
                x = 5+(105 * (i % 3));
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
                [imageview setImageWithURL:[NSURL URLWithString:[picDic objectForKey:@"fileId"]]];
                imageview.tag = i;
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPic:)];
                [imageview addGestureRecognizer:tap];
                [cell.contentView addSubview:imageview];
            }
        }
        return cell;
    }else{
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
        [cell.commentlabel setFrame:CGRectMake(cell.commentlabel.frame.origin.x, cell.commentlabel.frame.origin.y, size.width, size.height)];
        
        if ([Utils isBlankString:fileid]) {
            [cell.img setImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        }else{
            //            [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"nopicture2.png"]];
            [cell.img setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    if (row == 0) {
        NSInteger row = [indexPath row];
        // 列寬
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width;
        // 用何種字體進行顯示
        UIFont *font = [UIFont systemFontOfSize:17];
        // 該行要顯示的內容
        NSString *content = [[self.dataSource objectAtIndex:row] objectForKey:@"tncontent"];
        //    NSString *content = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        // 計算出顯示完內容需要的最小尺寸
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        size.height = size.height+106;
        
        NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
        NSArray *filelist = [data objectForKey:@"picList"];
        if ([filelist count] > 0) {
            int count = 0;
            if ([filelist count] % 3 == 0) {
                count = (int)([filelist count] / 3);
            }else{
                count = (int)([filelist count] / 3 + 1);
            }
            size.height = size.height + 100 * count + 5;
        }
        return size.height;
    }else{
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
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
