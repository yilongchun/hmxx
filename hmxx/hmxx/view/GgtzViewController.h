//
//  GgtzViewController.h
//  hmjz
//  公告通知
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GgtzViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{

}

@property (nonatomic, strong) UITableView *mytableView;
@property (nonatomic, strong) NSMutableArray *dataSource;



@end
