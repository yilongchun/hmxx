//
//  GgxqViewController.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "DaishGgtzViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "MKNetworkKit.h"
#import "ContentCell.h"
#import "SRRefreshView.h"

@interface DaishGgtzViewController ()<SRRefreshDelegate>{
    MKNetworkEngine *engine;
    NSNumber *totalpage;
    NSNumber *page;
    NSNumber *rows;
    int tntype;
}

@property (nonatomic, strong) SRRefreshView         *slimeView;
@end

@implementation DaishGgtzViewController
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
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        [self.mytableview setFrame:CGRectMake(0, 0, self.mytableview.frame.size.width,self.mytableview.frame.size.height+64)];
    }
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.passBtn.layer.cornerRadius = 5.0f;
    
    
    [self.mytableview addSubview:self.slimeView];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
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

- (void)loadData{
    [self showHudInView:self.view hint:@""];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    [dic setValue:userid forKey:@"userId"];
    [dic setValue:self.tnid forKey:@"tnid"];
    
    
    MKNetworkOperation *op = [engine operationWithPath:@"/Notice/findbyid.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        //        NSString *msg = [resultDict objectForKey:@"msg"];
        //        NSString *code = [resultDict objectForKey:@"code"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                self.dataSource = [NSMutableArray arrayWithObject:data];
                NSNumber *type = [data objectForKey:@"tntype"];
                tntype = [type intValue];
                [self.mytableview reloadData];
                [self hideHud];
            }else{
                [self hideHud];
            }
        }else{
            [self hideHud];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        
    }];
    [engine enqueueOperation:op];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self dataSource] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
        cell.creater.text = [NSString stringWithFormat:@"%@  %@",noticename,self.creater];
        //    cell.content.text = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
        cell.content.numberOfLines = 0;
        cell.content.lineBreakMode = NSLineBreakByCharWrapping;
        [cell.content sizeToFit];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width ;
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth-16, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        [cell.content setFrame:CGRectMake(cell.content.frame.origin.x, cell.content.frame.origin.y, cell.content.frame.size.width, size.height)];
        return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
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
        return size.height+106;
    
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


- (IBAction)pass:(id)sender {
    [self showHudInView:self.view hint:@""];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.tnid forKey:@"noticeId"];
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolNotice/audit.do" params:dic httpMethod:@"GET"];
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
            [self hideHud];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            [self showHint:msg customView:imageview];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0f];
        }else{
            [self hideHud];
            [self showHint:msg];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        
    }];
    [engine enqueueOperation:op];
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGgtz" object:nil];
}
@end
