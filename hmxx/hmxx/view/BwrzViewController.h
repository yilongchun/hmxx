//
//  BwrzViewController.h
//  hmjs
//  班务日志
//  Created by yons on 14-12-2.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BwrzViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
