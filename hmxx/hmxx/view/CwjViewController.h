//
//  CwjViewController.h
//  hmjs
//
//  Created by yons on 15-2-5.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CwjViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString* examinetype;

@end
