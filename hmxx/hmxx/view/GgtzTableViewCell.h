//
//  GgtzTableViewCell.h
//  hmjz
//  公告通知cell
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GgtzTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *gtitle;
@property (weak, nonatomic) IBOutlet UILabel *gdispcription;
@property (weak, nonatomic) IBOutlet UILabel *gsource;
@property (weak, nonatomic) IBOutlet UILabel *gpinglun;
@property (weak, nonatomic) IBOutlet UILabel *gdate;
@end
