//
//  ShezhiViewController.h
//  hmjz
//  设置
//  Created by yons on 14-10-28.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShezhiViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *mytableview;

@end
