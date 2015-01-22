//
//  PurchaseDetailViewController.h
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseDetailViewController : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UITextField *supplierText;
@property (weak, nonatomic) IBOutlet UITextField *supplierQuText;
@property (weak, nonatomic) IBOutlet UITextField *numText;
@property (weak, nonatomic) IBOutlet UITextField *purchaserText;
@property (weak, nonatomic) IBOutlet UITextField *signerText;
@property (weak, nonatomic) IBOutlet UITextField *priceText;
@property (weak, nonatomic) IBOutlet UITextField *unitText;
@property (weak, nonatomic) IBOutlet UITextField *totalPriceText;
@property (weak, nonatomic) IBOutlet UITextView *remarkText;
@property (nonatomic, strong) NSDictionary *info;
@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;
@property (weak, nonatomic) IBOutlet UISwitch *myswitch;
@property (weak, nonatomic) IBOutlet UILabel *hasReceiptLabel;
@end
