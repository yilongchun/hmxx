//
//  BbspViewController.h
//  hmjz
//  宝宝食谱
//  Created by yons on 14-11-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BbspViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSArray *dataSource;
@end
