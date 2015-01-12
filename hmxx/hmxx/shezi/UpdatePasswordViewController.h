//
//  UpdatePasswordViewController.h
//  hmjz
//  修改密码
//  Created by yons on 14-11-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdatePasswordViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;



@end
