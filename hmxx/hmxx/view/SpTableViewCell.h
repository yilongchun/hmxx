//
//  SpTableViewCell.h
//  hmjz
//  食谱单元格
//  Created by yons on 14-11-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *contentlabel;

@end
