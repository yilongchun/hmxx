//
//  GgtzTableViewCell.m
//  hmjz
//
//  Created by yons on 14-10-24.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "GgtzTableViewCell.h"

@implementation GgtzTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect

{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    
    //上分割线，
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(5, 0, rect.size.width - 10, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:42/255.0 green:173/255.0 blue:128/255.0 alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageview.layer.cornerRadius = 5;
    self.imageview.layer.masksToBounds = YES;
}


@end
