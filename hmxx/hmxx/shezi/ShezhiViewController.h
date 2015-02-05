//
//  ShezhiViewController.h
//  hmjz
//  设置
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface ShezhiViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) UIAlertController *alert;
@end
