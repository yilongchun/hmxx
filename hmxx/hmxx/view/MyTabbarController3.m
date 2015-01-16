//
//  MyTabbarController3.m
//  hmxx
//
//  Created by yons on 15-1-14.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyTabbarController3.h"
#import "DaiShGgViewController.h"
#import "DaiShHdViewController.h"

@interface MyTabbarController3 ()

@end

@implementation MyTabbarController3

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    UIImage *img1 = [UIImage imageNamed:@"daishenhegg2.png"];
    UIImage *img1_h = [UIImage imageNamed:@"daishenhegg1.png"];
    
    UIImage *img2 = [UIImage imageNamed:@"daishenhehd2.png"];
    UIImage *img2_h = [UIImage imageNamed:@"daishenhehd1.png"];
    
    DaiShGgViewController *vc1 = [[DaiShGgViewController alloc] init];
    DaiShHdViewController *vc2 = [[DaiShHdViewController alloc] init];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"待审核公告" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"待审核活动" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"待审核公告" image:img1 tag:0];
        vc1.tabBarItem = item1;
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"待审核活动" image:img2 tag:1];
        vc2.tabBarItem = item2;
    }
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"待审核公告";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"待审核公告";
    }else if (item.tag == 1){
        self.title = @"待审核活动";
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
