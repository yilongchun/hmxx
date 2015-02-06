//
//  CollectionViewController.h
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"

@interface CollectionViewController : UIViewController<LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *mycollectionview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString* examinetype;
@property (nonatomic, strong) NSString *examinedate;
@property (nonatomic, strong) NSString *classid;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@end
