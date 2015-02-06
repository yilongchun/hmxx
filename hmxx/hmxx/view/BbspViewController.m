//
//  BbspViewController.m
//  hmjz
//
//  Created by yons on 14-11-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "BbspViewController.h"
#import "Utils.h"
#import "UIImageView+AFNetworking.h"
#import "SpTableViewCell.h"

@interface BbspViewController ()

@end

@implementation BbspViewController
@synthesize mytableview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [mytableview setTableFooterView:v];
    if ([mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [mytableview setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [mytableview setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDatasource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self dataSource] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"spcell";
    SpTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpTableViewCell" owner:self options:nil] lastObject];
        
    }
    NSDictionary *data = [self.dataSource objectAtIndex:indexPath.row];
    NSString *cookbookType = [data objectForKey:@"cookbookType"];
    NSString *content = [data objectForKey:@"content"];
    NSString *fileid = [data objectForKey:@"fileid"];
    cell.titlelabel.text = cookbookType;
    cell.contentlabel.text = content;
    [cell.contentlabel sizeToFit];
    if ([Utils isBlankString:fileid]) {
        [cell.img setImage:[UIImage imageNamed:@"nopicture.png"]];
    }else{
//        [cell.img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/image/show.do?id=%@",[Utils getImageHostname],fileid]] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        [cell.img setImageWithURL:[NSURL URLWithString:fileid] placeholderImage:[UIImage imageNamed:@"nopicture.png"]];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
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
