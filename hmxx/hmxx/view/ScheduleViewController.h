//
//  ScheduleViewController.h
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *type;
@end
