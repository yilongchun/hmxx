//
//  PurchaseDetailViewController.m
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PurchaseDetailViewController.h"

@interface PurchaseDetailViewController ()

@end

@implementation PurchaseDetailViewController
@synthesize info;
@synthesize myscrollview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [myscrollview setContentSize:CGSizeMake(self.view.frame.size.width, 560)];
    
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    self.typeBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.typeBtn.layer.borderWidth = 0.4f;
    self.typeBtn.layer.cornerRadius = 5.0f;
    self.dateBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.dateBtn.layer.borderWidth = 0.4f;
    self.dateBtn.layer.cornerRadius = 5.0f;
    self.remarkText.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.remarkText.layer.borderWidth = 0.4f;
    self.remarkText.layer.cornerRadius = 5.0f;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y, [UIScreen mainScreen].bounds.size.width-self.remarkText.frame.origin.x-8, self.remarkText.frame.size.height)];
        

    }else{

    }
    NSString *typeName = [info objectForKey:@"typeName"];
    NSString *supplier = [info objectForKey:@"supplier"];
    NSString *supplierQu = [info objectForKey:@"supplierQu"];
    NSNumber *num = [info objectForKey:@"num"];
    NSString *unit = [info objectForKey:@"unit"];
    NSString *purchaser = [info objectForKey:@"purchaser"];
    NSString *signer = [info objectForKey:@"signer"];
    NSNumber *totalPrice = [info objectForKey:@"totalPrice"];
    NSString *purchaseDate = [info objectForKey:@"purchaseDate"];
    NSNumber *price = [info objectForKey:@"price"];
    NSString *remark = [info objectForKey:@"remark"];
    NSNumber *hasReceiptNum = [info objectForKey:@"hasReceipt"];
 
    [self.typeBtn setTitle:typeName forState:UIControlStateNormal];
    [self.dateBtn setTitle:purchaseDate forState:UIControlStateNormal];
    self.supplierText.text = supplier;
    self.supplierQuText.text = supplierQu;
    self.numText.text = [NSString stringWithFormat:@"%d",[num intValue]];
    self.priceText.text = [NSString stringWithFormat:@"%.2f",[price doubleValue]];
    self.purchaserText.text = purchaser;
    self.signerText.text = signer;
    self.unitText.text = unit;
    self.totalPriceText.text = [NSString stringWithFormat:@"%.2f",[totalPrice doubleValue]];
    self.remarkText.text = remark;
    [self.myswitch setOn:[hasReceiptNum boolValue]];
    if ([self.myswitch isOn]) {
        self.hasReceiptLabel.text = @"有";
    }else{
        self.hasReceiptLabel.text = @"无";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
