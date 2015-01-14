//
//  AddActivityViewController.h
//  hmjs
//
//  Created by yons on 14-12-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePickerHeader.h"

@interface AddActivityViewController : UIViewController<ELCImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *chosenImages;

@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextview;
@property (weak, nonatomic) IBOutlet UIButton *imagePickBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;


- (IBAction)launchController;
@end
