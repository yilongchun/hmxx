//
//  DaishGgtzViewController.h
//  hmxx
//
//  Created by yons on 15-1-15.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaishGgtzViewController : UIViewController{
    UIView *containerView;
}

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic,copy) NSString *tnid;//公告id
@property(nonatomic,copy) NSString *creater;
@property (weak, nonatomic) IBOutlet UIButton *passBtn;
- (IBAction)pass:(id)sender;
@end
