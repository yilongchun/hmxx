//
//  PurchaseReportViewController.h
//  hmxx
//
//  Created by yons on 15-1-24.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseReportViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *year;
@end
