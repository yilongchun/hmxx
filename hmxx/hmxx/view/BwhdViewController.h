//
//  BwhdViewController.h
//  hmjz
//  班务活动
//  Created by yons on 14-10-23.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BwhdViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;


@end
