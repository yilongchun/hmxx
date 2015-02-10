//
//  XsydDetailViewController.m
//  hmxx
//
//  Created by yons on 15-2-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XsydDetailViewController.h"
#import "MKNetworkKit.h"
#import "MBProgressHUD.h"
#import "Utils.h"
#import "ExpansionTableViewCell.h"

@interface XsydDetailViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    NSString *schoolid;
    
    BOOL isOpen;
    NSIndexPath *selectedIndex;
}

@end

@implementation XsydDetailViewController
@synthesize mytableview;
@synthesize dataSource;
@synthesize occurdate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"异动详情";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    schoolid = [userDefaults objectForKey:@"schoolid"];
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //初始化tableview
    CGRect cg;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        cg = CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
        self.automaticallyAdjustsScrollViewInsets = NO;
    }else{
        cg = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height-64);
    }
    mytableview = [[UITableView alloc] initWithFrame:cg style:UITableViewStylePlain];
    mytableview.dataSource = self;
    mytableview.delegate = self;
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
    [self.view addSubview:mytableview];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    //初始化数据
    [self loadData];
}

//加载数据
- (void)loadData{
    [HUD show:YES];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:occurdate forKey:@"occurdate"];
    MKNetworkOperation *op = [engine operationWithPath:@"/schooltransfer/findAllList.do" params:dic httpMethod:@"GET"];
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
            NSArray *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                
                NSMutableArray *array = [NSMutableArray array];
                
                for (int i = 0 ; i < data.count; i++) {
                    
                    BOOL flag = YES;
                    NSMutableArray *infoarray = [NSMutableArray array];
                    NSDictionary *info = [data objectAtIndex:i];
                    NSString *classid = [info objectForKey:@"classid"];
                    
                    for (int j = 0; j < array.count; j++) {
                        NSDictionary *tempdic = [array objectAtIndex:j];
                        NSString *tempclassid = [tempdic objectForKey:@"classid"];
                        if ([tempclassid isEqualToString:classid]) {
                            NSMutableArray *tempinfoarray = [tempdic objectForKey:@"infoarray"];
                            [tempinfoarray addObject:info];
                            flag = NO;
                            break;
                        }
                    }
                    
                    if (flag) {
                        NSString *classname = [info objectForKey:@"classname"];
                        NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
                        [infoDic setValue:classid forKey:@"classid"];
                        [infoDic setValue:classname forKey:@"classname"];
                        [infoarray addObject:info];
                        [infoDic setObject:infoarray forKey:@"infoarray"];
                        [array addObject:infoDic];
                    }
                }
                
                NSLog(@"%@",array);
                
                
                dataSource = [NSMutableArray arrayWithArray:array];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (isOpen) {
        NSDictionary *info = [dataSource objectAtIndex:selectedIndex.row];
        NSArray *infoarray = [info objectForKey:@"infoarray"];
        return [self.dataSource count]+[infoarray count];
    }else{
        return [self.dataSource count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];;
    }
    
    if (isOpen) {
        NSDictionary *info = [dataSource objectAtIndex:selectedIndex.row];
        NSArray *infoarray = [info objectForKey:@"infoarray"];
        if(indexPath.row <= selectedIndex.row){
            
            static NSString *cellIdentifier = @"expancell";
            ExpansionTableViewCell *expancell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!expancell) {
                expancell = [[[NSBundle mainBundle] loadNibNamed:@"ExpansionTableViewCell" owner:self options:nil] lastObject];
            }
            NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
            NSString *classname = [info objectForKey:@"classname"];
            NSArray *infoarray = [info objectForKey:@"infoarray"];
            expancell.label1.text = classname;
            expancell.label2.text = [NSString stringWithFormat:@"异动%d人",[infoarray count]];
            if (indexPath.row == selectedIndex.row) {
                [expancell changeArrowWithUp:isOpen];
            }else{
                [expancell changeArrowWithUp:NO];
            }
            return expancell;
            
            
            
        }else if(indexPath.row <= selectedIndex.row + infoarray.count){
            
            NSDictionary *info = [infoarray objectAtIndex:(indexPath.row - selectedIndex.row - 1)];
            NSString *studentname = [info objectForKey:@"studentname"];
            NSString *bak = [info objectForKey:@"bak"];
            NSString *detail = [info objectForKey:@"detail"];
            NSNumber *type = [info objectForKey:@"type"];
            
            NSMutableString *content = [NSMutableString stringWithFormat:@"姓名    %@\n\n",studentname];
            if ([type intValue] == 0) {
                [content appendString:[NSString stringWithFormat:@"类型    转入\n\n"]];
            }else if ([type intValue] == 1){
                [content appendString:[NSString stringWithFormat:@"类型    转出\n\n"]];
            }
            [content appendString:[NSString stringWithFormat:@"原因    %@\n\n",detail]];
            [content appendString:[NSString stringWithFormat:@"备注    %@",bak]];
            
            
            cell.textLabel.text = content;
            [cell.textLabel sizeToFit];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            return cell;
        }else{
            static NSString *cellIdentifier = @"expancell";
            ExpansionTableViewCell *expancell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!expancell) {
                expancell = [[[NSBundle mainBundle] loadNibNamed:@"ExpansionTableViewCell" owner:self options:nil] lastObject];
            }
            NSDictionary *info = [dataSource objectAtIndex:indexPath.row - infoarray.count];
            NSString *classname = [info objectForKey:@"classname"];
            NSArray *infoarray = [info objectForKey:@"infoarray"];
            expancell.label1.text = classname;
            expancell.label2.text = [NSString stringWithFormat:@"异动%d人",[infoarray count]];
            if (indexPath.row == selectedIndex.row) {
                [expancell changeArrowWithUp:isOpen];
            }else{
                [expancell changeArrowWithUp:NO];
            }
            return expancell;
        }
    }else{
        static NSString *cellIdentifier = @"expancell";
        ExpansionTableViewCell *expancell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!expancell) {
            expancell = [[[NSBundle mainBundle] loadNibNamed:@"ExpansionTableViewCell" owner:self options:nil] lastObject];
        }
        NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
        NSString *classname = [info objectForKey:@"classname"];
        NSArray *infoarray = [info objectForKey:@"infoarray"];
        expancell.label1.text = classname;
        expancell.label2.text = [NSString stringWithFormat:@"异动%d人",[infoarray count]];
        if (indexPath.row == selectedIndex.row) {
            [expancell changeArrowWithUp:isOpen];
        }else{
            [expancell changeArrowWithUp:NO];
        }
        return expancell;
    }
    
    
    
    
//    NSString *bak = [info objectForKey:@"bak"];
//    NSString *detail = [info objectForKey:@"detail"];
//    NSString *classname = [info objectForKey:@"classname"];
//    NSString *createDate = [info objectForKey:@"createDate"];
//    NSNumber *type = [info objectForKey:@"type"];
//    NSString *studentname = [info objectForKey:@"studentname"];
//    NSString *creator = [info objectForKey:@"creator"];
    
    
//
//    switch (indexPath.row) {
//        case 0:
//            cell.textLabel.text = [NSString stringWithFormat:@"日期    %@",createDate];
//            break;
//        case 1:
//            cell.textLabel.text = [NSString stringWithFormat:@"班级    %@",classname];
//            break;
//        case 2:
//            cell.textLabel.text = [NSString stringWithFormat:@"姓名    %@",studentname];
//            break;
//        case 3:
//            if ([type isEqualToNumber:[NSNumber numberWithInt:0]]) {
//                cell.textLabel.text = [NSString stringWithFormat:@"类型    转入"];
//            }else if ([type isEqualToNumber:[NSNumber numberWithInt:1]]){
//                cell.textLabel.text = [NSString stringWithFormat:@"类型    转出"];
//            }
//            break;
//        case 4:
//            cell.textLabel.text = [NSString stringWithFormat:@"原因    %@",detail];
//            [cell.textLabel sizeToFit];
//            cell.textLabel.numberOfLines = 0;
//            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            break;
//        case 5:
//            cell.textLabel.text = [NSString stringWithFormat:@"备注    %@",bak];
//            [cell.textLabel sizeToFit];
//            cell.textLabel.numberOfLines = 0;
//            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//            break;
//        case 6:
//            cell.textLabel.text = [NSString stringWithFormat:@"发布人    %@",creator];
//            break;
//        default:
//            break;
//    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    float width = [UIScreen mainScreen].bounds.size.width;
//    CGSize size = CGSizeMake(width-30,CGFLOAT_MAX);
//    if (indexPath.row == 4) {
//        NSString *detail = [self.info objectForKey:@"detail"];
//        NSString *strTest = [NSString stringWithFormat:@"原因\t%@",detail];
//        CGSize labelsize = [strTest sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
//        if (labelsize.height+20 < 44) {
//            return 44;
//        }else{
//            return labelsize.height+20;
//        }
//    }else if(indexPath.row == 5){
//        NSString *bak = [self.info objectForKey:@"bak"];
//        NSString *strTest = [NSString stringWithFormat:@"备注\t%@",bak];
//        CGSize labelsize = [strTest sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
//        if (labelsize.height+20 < 44) {
//            return 44;
//        }else{
//            return labelsize.height+20;
//        }
//    }
//    else{
//        return 44;
//    }
    
    
    if (isOpen) {
        NSDictionary *info = [dataSource objectAtIndex:selectedIndex.row];
        NSArray *infoarray = [info objectForKey:@"infoarray"];
        if(indexPath.row <= selectedIndex.row){
            return 50;
        }else if(indexPath.row <= selectedIndex.row + infoarray.count){
            float width = [UIScreen mainScreen].bounds.size.width;
            CGSize size = CGSizeMake(width-30,CGFLOAT_MAX);
            
            info = [infoarray objectAtIndex:(indexPath.row - selectedIndex.row - 1)];
            
            NSString *studentname = [info objectForKey:@"studentname"];
            NSString *bak = [info objectForKey:@"bak"];
            NSString *detail = [info objectForKey:@"detail"];
            NSNumber *type = [info objectForKey:@"type"];
            
            NSMutableString *content = [NSMutableString stringWithFormat:@"姓名    %@\n\n",studentname];
            if ([type intValue] == 0) {
                [content appendString:[NSString stringWithFormat:@"类型    转入\n\n"]];
            }else if ([type intValue] == 1){
                [content appendString:[NSString stringWithFormat:@"类型    转出\n\n"]];
            }
            [content appendString:[NSString stringWithFormat:@"原因    %@\n\n",detail]];
            [content appendString:[NSString stringWithFormat:@"备注    %@",bak]];
            CGSize labelsize = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
            
            return labelsize.height + 20;
        }else{
            return 50;
        }
    }else{
        return 50;
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
    [tableView beginUpdates];
    
    if(selectedIndex == nil){
        isOpen = YES;
        selectedIndex = indexPath;
        NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
        NSArray *infoarray = [info objectForKey:@"infoarray"];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0 ; i < infoarray.count ; i++ ) {
            NSIndexPath *nextindex1 = [NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0];
            [indexPaths addObject:nextindex1];
        }
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        ExpansionTableViewCell *cell = (ExpansionTableViewCell *)[tableView cellForRowAtIndexPath:selectedIndex];
        [cell changeArrowWithUp:YES];
    }
    else{
        if (indexPath.row == selectedIndex.row) {
            isOpen = !isOpen;
            selectedIndex = nil;
            ExpansionTableViewCell *cell = (ExpansionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell changeArrowWithUp:NO];
            NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
            NSArray *infoarray = [info objectForKey:@"infoarray"];
            
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0 ; i < infoarray.count ; i++ ) {
                NSIndexPath *nextindex1 = [NSIndexPath indexPathForRow:indexPath.row+i+1 inSection:0];
                [indexPaths addObject:nextindex1];
            }
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }else{
            isOpen = NO;
            ExpansionTableViewCell *cell = (ExpansionTableViewCell *)[tableView cellForRowAtIndexPath:selectedIndex];
            [cell changeArrowWithUp:NO];
            NSDictionary *info = [dataSource objectAtIndex:selectedIndex.row];
            NSArray *infoarray = [info objectForKey:@"infoarray"];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for (int i = 0 ; i < infoarray.count ; i++ ) {
                NSIndexPath *nextindex1 = [NSIndexPath indexPathForRow:selectedIndex.row+i+1 inSection:0];
                [indexPaths addObject:nextindex1];
            }
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            
            isOpen = YES;
            if (indexPath.row > selectedIndex.row) {
                selectedIndex = [NSIndexPath indexPathForRow:indexPath.row-infoarray.count inSection:0];
            }else{
                selectedIndex = indexPath;
            }
            NSDictionary *info2 = [dataSource objectAtIndex:selectedIndex.row];
            NSArray *infoarray2 = [info2 objectForKey:@"infoarray"];
            NSMutableArray *indexPaths2 = [NSMutableArray array];
            for (int i = 0 ; i < infoarray2.count ; i++ ) {
                NSIndexPath *nextindex1 = [NSIndexPath indexPathForRow:selectedIndex.row+i+1 inSection:0];
                [indexPaths2 addObject:nextindex1];
            }
            [tableView insertRowsAtIndexPaths:indexPaths2 withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    [tableView endUpdates];
    ExpansionTableViewCell *cell = (ExpansionTableViewCell *)[tableView cellForRowAtIndexPath:selectedIndex];
    [cell changeArrowWithUp:isOpen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
