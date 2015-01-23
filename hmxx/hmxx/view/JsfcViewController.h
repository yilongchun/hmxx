//
//  JsfcViewController.h
//  hmxx
//
//  Created by yons on 15-1-23.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JsfcViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
