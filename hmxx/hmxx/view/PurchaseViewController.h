//
//  PurchaseViewController.h
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end
