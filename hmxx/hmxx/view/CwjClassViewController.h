//
//  CwjClassViewController.h
//  hmxx
//
//  Created by yons on 15-2-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CwjClassViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString* examinetype;
@property (nonatomic, strong) NSString* examinedate;

@end
