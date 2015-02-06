//
//  CwjTabBarController.m
//  hmjs
//
//  Created by yons on 15-1-28.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import "CwjTabBarController.h"
#import "CollectionViewController.h"
#import "CwjViewController.h"

@interface CwjTabBarController (){
    NSString *type;
}

@end

@implementation CwjTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.backBarButtonItem = backItem;
    backItem.title = @"返回";
    
    //    初始化第一个视图控制器
//    CollectionViewController *vc1 = [[CollectionViewController alloc] init];
    CwjViewController *vc1 = [[CwjViewController alloc] init];
    vc1.examinetype = @"1";
    vc1.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"晨检" image:[UIImage imageNamed:@""] tag:0];
    
    
    //    初始化第二个视图控制器
//    CollectionViewController *vc2 = [[CollectionViewController alloc] init];
    CwjViewController *vc2 = [[CwjViewController alloc] init];
    vc2.examinetype = @"2";
    vc2.tabBarItem =[[UITabBarItem alloc] initWithTitle:@"午检" image:[UIImage imageNamed:@""] tag:1];
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"晨检";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    type = @"1";
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"晨检";
        type = @"1";
    }else if (item.tag == 1){
        self.title = @"午检";
        type = @"2";
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
