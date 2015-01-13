//
//  MyTabbarController.m
//  hmjz
//
//  Created by yons on 14-11-20.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "MyTabbarController.h"
#import "YqjsViewController.h"



@interface MyTabbarController ()

@end

@implementation MyTabbarController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    UIImage *img1 = [UIImage imageNamed:@"yuanqingjieshao2.png"];
    UIImage *img1_h = [UIImage imageNamed:@"yuanqingjieshao1.png"];
    
    
    
    
    YqjsViewController *vc1 = [[YqjsViewController alloc] init];
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"园情介绍" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"园情介绍" image:img1 tag:0];
        vc1.tabBarItem = item1;
        
        
    }
    
    
    //    初始化第二个视图控制器
    UIViewController *vc2 = [[UIViewController alloc] init];
    [vc2.view setBackgroundColor:[UIColor whiteColor]];
    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"教师风采" image:[UIImage imageNamed:@"ic_bwrz_002.png"] tag:1];
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"园情介绍";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
    
    
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"园情介绍";
    }else if (item.tag == 1){
        self.title = @"教师风采";
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
