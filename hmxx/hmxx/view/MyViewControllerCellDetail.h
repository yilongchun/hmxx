//
//  MyViewControllerCellDetail.h
//  hmjz
//  班务活动详情
//  Created by yons on 14-10-30.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"


@interface MyViewControllerCellDetail : UIViewController<HPGrowingTextViewDelegate>{
    UIView *containerView;
    HPGrowingTextView *textView;
    
}

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic,copy) NSString *detailid;
@property (nonatomic,copy) NSString *title;



//-(void)resignTextView;

@end
