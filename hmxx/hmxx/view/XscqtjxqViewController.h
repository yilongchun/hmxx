//
//  XscqtjxqViewController.h
//  hmxx
//
//  Created by yons on 15-1-14.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XscqtjxqViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    
}

@property (nonatomic, strong) UITableView *mytableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSDictionary *info;

@end