//
//  AddScheduleViewController.h
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddScheduleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *mytextview;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scheduleTypeSegmented;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (nonatomic, strong) NSString *type;

@end
