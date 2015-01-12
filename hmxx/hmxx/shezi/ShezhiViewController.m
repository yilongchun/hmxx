//
//  ShezhiViewController.m
//  hmjz
//
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "ShezhiViewController.h"
#import "LoginViewController.h"
#import "YjfkViewController.h"
#import "UpdatePasswordViewController.h"

@interface ShezhiViewController ()

@end

@implementation ShezhiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    [self.navigationController setNavigationBarHidden:NO];
    
    [self drawTableView];
}

-(void)drawTableView{
    
    UITableView *tview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    [tview setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1]];
    [tview setDelegate:self];
    [tview setDataSource:self];
    [tview setScrollEnabled:YES];
//    if ([tview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([tview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tview setLayoutMargins:UIEdgeInsetsZero];
//    }
    [self.view addSubview:tview];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        switch (section) {
            case 0:
                if(row == 0)
                {
                    cell.textLabel.text =  @"意见反馈";
                }else if(row == 1){
                    cell.textLabel.text =  @"修改密码";
                }
//                else if(row == 2){
//                    cell.textLabel.text =  @"版本更新";
//                }
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text =  @"退出登录";
                [cell.textLabel setTextColor:[UIColor redColor]];
                [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
                break;
            efault:
                break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            YjfkViewController *vc = [[YjfkViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1){
            UpdatePasswordViewController *vc = [[UpdatePasswordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }else{
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"确定要退出吗?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil];
        actionsheet.tag = 100;
        [actionsheet showInView:self.view];
        
        
//        for (UIViewController *temp in self.navigationController.viewControllers) {
//            if ([temp isKindOfClass:[LoginViewController class]]) {
//                [self.navigationController setNavigationBarHidden:YES];
//                [self.navigationController popToViewController:temp animated:YES];
//                
//                break;
//            }
//        }
        
        
        
        
//        LoginViewController *loginCtrl = [[LoginViewController alloc] init];
//        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:loginCtrl];
//        [navCtrl setNavigationBarHidden:YES];
//        self.view.window.rootViewController = navCtrl;
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            //退出登陆
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
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
