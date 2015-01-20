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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.typeBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
        self.typeBtn.layer.borderWidth = 0.4f;
        self.typeBtn.layer.cornerRadius = 5.0f;
        self.dateBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
        self.dateBtn.layer.borderWidth = 0.4f;
        self.dateBtn.layer.cornerRadius = 5.0f;
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
