//
//  ScheduleDetailViewController.h
//  hmxx
//
//  Created by yons on 15-1-22.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleDetailViewController : UIViewController
@property(nonatomic,strong) NSString *detailId;
@property (nonatomic, copy) NSNumber *type;
@property (nonatomic, copy) NSNumber *roletype;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *mytextview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scheduleTypeSegmented;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@end
