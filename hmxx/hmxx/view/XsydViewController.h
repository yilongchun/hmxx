//
//  XsydViewController.h
//  hmxx
//
//  Created by yons on 15-2-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XsydViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
