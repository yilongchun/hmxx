//
//  ReportFirstTableViewCell.h
//  hmxx
//
//  Created by yons on 15-1-26.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportFirstTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic) BOOL isExpansion;

@end
