//
//  XsydDetailViewController.h
//  hmxx
//
//  Created by yons on 15-2-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XsydDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSDictionary *info;

@end
