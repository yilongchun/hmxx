//
//  KcbViewController.h
//  hmjz
//  课程表
//  Created by yons on 14-10-31.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KcbViewController : UIViewController

@property (nonatomic, strong) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UILabel *leftContent;
@property (weak, nonatomic) IBOutlet UILabel *rightContent;
@property (weak, nonatomic) IBOutlet UIImageView *conBackground;

@end
