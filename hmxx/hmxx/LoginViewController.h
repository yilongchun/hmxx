//
//  LoginViewController.h
//  hmxx
//  登陆
//  Created by yons on 14-10-22.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface LoginViewController : UIViewController<UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic) MainViewController *mainController;

- (IBAction)login:(id)sender;
@end
