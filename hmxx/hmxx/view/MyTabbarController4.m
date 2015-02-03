//
//  MyTabbarController4.m
//  hmxx
//
//  Created by yons on 15-1-21.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyTabbarController4.h"
#import "ScheduleViewController.h"
#import "AddScheduleViewController.h"

@interface MyTabbarController4 (){
    int type;
}

@end

@implementation MyTabbarController4

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *userdata = [userdefault objectForKey:@"user"];
    NSNumber *roletype = [userdata objectForKey:@"roletype"];
    
    if ([roletype intValue] == 3) {
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(action1)];
        [self.navigationItem setRightBarButtonItem:addItem];
    }
    
    
    
    UIImage *img1 = [UIImage imageNamed:@"planmanage2.png"];
    UIImage *img1_h = [UIImage imageNamed:@"planmanage1.png"];
    
    UIImage *img2 = [UIImage imageNamed:@"summarymanage2.png"];
    UIImage *img2_h = [UIImage imageNamed:@"summarymanage1.png"];
    
    ScheduleViewController *vc1 = [[ScheduleViewController alloc] init];
    vc1.type = [NSNumber numberWithInt:2];
    ScheduleViewController *vc2 = [[ScheduleViewController alloc] init];
    vc2.type = [NSNumber numberWithInt:1];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"计划管理" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"总结管理" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"计划管理" image:img1 tag:0];
        vc1.tabBarItem = item1;
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"总计管理" image:img2 tag:1];
        vc2.tabBarItem = item2;
    }
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"计划管理";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"计划管理";
        type = 2;
    }else if (item.tag == 1){
        self.title = @"总结管理";
        type = 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)action1{
    AddScheduleViewController *vc = [[AddScheduleViewController alloc] init];
    vc.type = [NSString stringWithFormat:@"%d",type];
    [self.navigationController pushViewController:vc animated:YES];
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
