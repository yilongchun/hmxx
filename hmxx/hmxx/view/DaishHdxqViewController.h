//
//  DaishHdxqViewController.h
//  hmxx
//
//  Created by yons on 15-1-15.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DaishHdxqViewController : UIViewController{
    UIView *containerView;
    
}

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *detailid;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *creater;
@property (weak, nonatomic) IBOutlet UIButton *passBtn;
- (IBAction)pass:(id)sender;

@end
