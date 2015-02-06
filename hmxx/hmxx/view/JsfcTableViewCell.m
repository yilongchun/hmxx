//
//  JsfcTableViewCell.m
//  hmxx
//
//  Created by yons on 15-1-23.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "JsfcTableViewCell.h"

@implementation JsfcTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    //下分割线
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
//}

@end
