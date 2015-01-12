//
//  GuideViewController.m
//  hmjz
//
//  Created by yons on 14-12-1.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GuideViewController.h"
#import "LoginViewController.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.guideScrollView.bounces = NO;
    self.guideScrollView.showsHorizontalScrollIndicator = NO;
    self.guideScrollView.showsVerticalScrollIndicator = NO;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.guideScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*4, [UIScreen mainScreen].bounds.size.height);
    }else{
        self.guideScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width*4, [UIScreen mainScreen].bounds.size.height-20);
    }
    self.guideScrollView.pagingEnabled = YES;
    for (int i=0; i<4; i++) {
        CGRect rect;
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
            rect = CGRectMake([UIScreen mainScreen].bounds.size.width*i, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }else{
            rect = CGRectMake([UIScreen mainScreen].bounds.size.width*i, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20);
        }
        UIImageView* imageView = [[UIImageView alloc ]initWithFrame:rect];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        switch (i) {
            case 0:
                imageView.image = [UIImage imageNamed:@"guide_1.png"];
                break;
            case 1:
                imageView.image = [UIImage imageNamed:@"guide_2.png"];
                break;
            case 2:
                imageView.image = [UIImage imageNamed:@"guide_3.png"];
                break;
            case 3:
                imageView.image = [UIImage imageNamed:@"guide_4.png"];
                break;
            default:
                break;
        }
        
        
        [self.guideScrollView addSubview:imageView];
//        if (i == 3) {
            UIButton* start = [UIButton buttonWithType:UIButtonTypeCustom];
            [start setImage:[UIImage imageNamed:@"start_open.png"] forState:UIControlStateNormal];
        start.frame = CGRectMake([UIScreen mainScreen].bounds.size.width*3+[UIScreen mainScreen].bounds.size.width/2-71, [UIScreen mainScreen].bounds.size.height < self.view.frame.size.height ? [UIScreen mainScreen].bounds.size.height/2+170 : [UIScreen mainScreen].bounds.size.height-100, 142, 44);
        [start.layer setMasksToBounds:YES];
        start.layer.cornerRadius = 5.0f;
//            start.layer.cornerRadius = 5;
//            start.layer.borderWidth = 0.5;
        
//        [start setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width*3+[UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2 + 200)];
        [start setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin];
//            [start setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [start addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
//            [start setTitle:@"Start" forState:UIControlStateNormal];
            [self.guideScrollView addSubview:start];
//        }
    }
}

- (void)closeView{
    UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
    [vc setNavigationBarHidden:YES];
    self.view.window.rootViewController = vc;
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
