//
//  XsydDetailViewController.m
//  hmxx
//
//  Created by yons on 15-2-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XsydDetailViewController.h"

@interface XsydDetailViewController ()

@end

@implementation XsydDetailViewController
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"异动详情";
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
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];;
    }
    
    NSString *bak = [self.info objectForKey:@"bak"];
    NSString *detail = [self.info objectForKey:@"detail"];
    NSString *classname = [self.info objectForKey:@"classname"];
    NSString *createDate = [self.info objectForKey:@"createDate"];
    NSNumber *type = [self.info objectForKey:@"type"];
    NSString *studentname = [self.info objectForKey:@"studentname"];
    NSString *creator = [self.info objectForKey:@"creator"];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = [NSString stringWithFormat:@"日期    %@",createDate];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"班级    %@",classname];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:@"姓名    %@",studentname];
            break;
        case 3:
            if ([type isEqualToNumber:[NSNumber numberWithInt:0]]) {
                cell.textLabel.text = [NSString stringWithFormat:@"类型    转入"];
            }else if ([type isEqualToNumber:[NSNumber numberWithInt:1]]){
                cell.textLabel.text = [NSString stringWithFormat:@"类型    转出"];
            }
            break;
        case 4:
            cell.textLabel.text = [NSString stringWithFormat:@"原因    %@",detail];
            [cell.textLabel sizeToFit];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            break;
        case 5:
            cell.textLabel.text = [NSString stringWithFormat:@"备注    %@",bak];
            [cell.textLabel sizeToFit];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            break;
        case 6:
            cell.textLabel.text = [NSString stringWithFormat:@"发布人    %@",creator];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float width = [UIScreen mainScreen].bounds.size.width;
    CGSize size = CGSizeMake(width-30,CGFLOAT_MAX);
    if (indexPath.row == 4) {
        NSString *detail = [self.info objectForKey:@"detail"];
        NSString *strTest = [NSString stringWithFormat:@"原因\t%@",detail];
        CGSize labelsize = [strTest sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        if (labelsize.height+20 < 44) {
            return 44;
        }else{
            return labelsize.height+20;
        }
    }else if(indexPath.row == 5){
        NSString *bak = [self.info objectForKey:@"bak"];
        NSString *strTest = [NSString stringWithFormat:@"备注\t%@",bak];
        CGSize labelsize = [strTest sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        if (labelsize.height+20 < 44) {
            return 44;
        }else{
            return labelsize.height+20;
        }
    }
    else{
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
