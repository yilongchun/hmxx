//
//  AddPuchaseViewController.h
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPuchaseViewController : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *typeBtn;
- (IBAction)chooseType:(id)sender;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end
