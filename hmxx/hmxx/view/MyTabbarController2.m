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
    
    
    UIImage *img1 = [UIImage imageNamed:@"huodongguanli2.png"];
    UIImage *img1_h = [UIImage imageNamed:@"huodongguanli1.png"];
    
    UIImage *img2 = [UIImage imageNamed:@"gonggaoguanli2.png"];
    UIImage *img2_h = [UIImage imageNamed:@"gonggaoguanli1.png"];
    
    UIImage *img3 = [UIImage imageNamed:@"yuanwurizhi2.png"];
    UIImage *img3_h = [UIImage imageNamed:@"yuanwurizhi1.png"];
    
    
    BwhdViewController *vc1 = [[BwhdViewController alloc] init];
    GgtzViewController *vc2 = [[GgtzViewController alloc] init];
    UIViewController *vc3 = [[UIViewController alloc] init];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img3 = [img3 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img3_h = [img3_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"活动管理" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"公告管理" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
        
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"园务日志" image:img3 selectedImage:img3_h];
        [item3 setTag:2];
        vc3.tabBarItem = item3;
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"活动管理" image:img1 tag:0];
        vc1.tabBarItem = item1;
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"公告管理" image:img2 tag:1];
        vc2.tabBarItem = item2;
        UITabBarItem *item3 = [[UITabBarItem alloc] initWithTitle:@"园务日志" image:img3 tag:2];
        vc3.tabBarItem = item3;
    }
    
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
