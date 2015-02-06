//
//  CollectionCell.m
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "CollectionCell.h"
#import "CustomCellBackground.h"

@implementation CollectionCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"CollectionCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
//        self.layer.cornerRadius = 5.0f;
    }
    return self;
}

//-(void)setHighlighted:(BOOL)highlighted{
//    [super setHighlighted:highlighted];
//    if (highlighted) {
//        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
//        self.selectedBackgroundView = backgroundView;
//    }else{
//        self.selectedBackgroundView = nil;
//    }
//}


@end
