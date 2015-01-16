//
//  UpdateBwrzViewController.h
//  hmjs
//
//  Created by yons on 14-12-9.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateBwrzViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *bjrs;
@property (weak, nonatomic) IBOutlet UITextField *cqrs;
@property (weak, nonatomic) IBOutlet UITextField *bjrs2;
@property (weak, nonatomic) IBOutlet UITextField *sjrs;
@property (weak, nonatomic) IBOutlet UITextField *cdrs;
@property (weak, nonatomic) IBOutlet UITextView *bjsj;
@property (weak, nonatomic) IBOutlet UILabel *dateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;

@property(nonatomic,copy) NSString *detailId;

@end
