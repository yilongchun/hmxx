//
//  AddNoticeViewController.h
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddNoticeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextview;


@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *title2;

- (IBAction)addBtn:(id)sender;

@end
