//
//  MoreTableViewCell.m
//  hmxx
//
//  Created by yons on 15-1-21.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MoreTableViewCell.h"

@implementation MoreTableViewCell
@synthesize moreButton;

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"MoreTableViewCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UITableViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
        
        moreButton.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
        moreButton.layer.borderWidth = 0.4f;
        moreButton.layer.cornerRadius = 5.0f;
        
//        UITapGestureRecognizer *click;
//        click = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click)];
//        click.numberOfTapsRequired = 1;
//        [self.moreBtn addGestureRecognizer:click];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
