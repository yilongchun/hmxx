//
//  PurchaseTypeDetailViewController.h
//  hmxx
//
//  Created by yons on 15-2-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseTypeDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, copy) NSString *purchaseType;
@property (nonatomic, copy) NSString *purchaseDate;
@property (nonatomic) BOOL isShow;

@end
