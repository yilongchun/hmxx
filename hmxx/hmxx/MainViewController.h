//
//  MainViewController.h
//  hmxx
//  首页
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@interface MainViewController : UIViewController<UINavigationControllerDelegate,UIScrollViewDelegate>{
    BOOL loginSuccess;
}


- (IBAction)setup:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIImageView *userimg;
@property (weak, nonatomic) IBOutlet UILabel *username;

@property (nonatomic, copy) NSString *flag;
@property (nonatomic, strong) NSMutableArray *menus;




@end
