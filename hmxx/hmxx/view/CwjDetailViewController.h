//
//  CwjDetailViewController.h
//  hmjs
//
//  Created by yons on 15-1-28.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CwjDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong) NSIndexPath *indexpath;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *mytextview1;
@property (weak, nonatomic) IBOutlet UITextField *temperatureText;
@property (weak, nonatomic) IBOutlet UITextField *mobileText;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end
