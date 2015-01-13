//
//  MyTabbarController2.m
//  hmxx
//
//  Created by yons on 15-1-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyTabbarController2.h"
#import "BwhdViewController.h"
#import "GgtzViewController.h"

@interface MyTabbarController2 ()

@end

@implementation MyTabbarController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"活动管理" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:0];
    
    GgtzViewController *vc2 = [[GgtzViewController alloc] init];
    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"公告管理" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:1];
    
    UIViewController *vc3 = [[UIViewController alloc] init];
    [vc3.view setBackgroundColor:[UIColor whiteColor]];
    vc3.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"园务日志" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:2];
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2,vc3, nil];
    
    self.title = @"活动管理";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"活动管理";
    }else if (item.tag == 1){
        self.title = @"公告管理";
    }else if (item.tag == 2){
        self.title = @"园务日志";
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
