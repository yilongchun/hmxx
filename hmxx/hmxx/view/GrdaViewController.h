//
//  GrdaViewController.h
//  hmjz
//  个人档案
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrdaViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myimageview;
@property (weak, nonatomic) IBOutlet UITableView *mytableview;

@end
