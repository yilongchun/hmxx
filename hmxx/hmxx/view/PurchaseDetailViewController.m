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
        
        
        
        if (self.remarkText.frame.size.height + self.remarkText.frame.origin.y > [UIScreen mainScreen].bounds.size.height) {
            [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y, [UIScreen mainScreen].bounds.size.width-self.remarkText.frame.origin.x-8, [UIScreen mainScreen].bounds.size.height - self.remarkText.frame.origin.y-8)];
        }else{
            [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y, [UIScreen mainScreen].bounds.size.width-self.remarkText.frame.origin.x-8, self.remarkText.frame.size.height)];
        }
    }else{
        [self.label1 setFrame:CGRectMake(self.label1.frame.origin.x, self.label1.frame.origin.y-64, self.label1.frame.size.width, self.label1.frame.size.height)];
        [self.label2 setFrame:CGRectMake(self.label2.frame.origin.x, self.label2.frame.origin.y-64, self.label2.frame.size.width, self.label2.frame.size.height)];
        [self.label3 setFrame:CGRectMake(self.label3.frame.origin.x, self.label3.frame.origin.y-64, self.label3.frame.size.width, self.label3.frame.size.height)];
        [self.label4 setFrame:CGRectMake(self.label4.frame.origin.x, self.label4.frame.origin.y-64, self.label4.frame.size.width, self.label4.frame.size.height)];
        [self.label5 setFrame:CGRectMake(self.label5.frame.origin.x, self.label5.frame.origin.y-64, self.label5.frame.size.width, self.label5.frame.size.height)];
        [self.label6 setFrame:CGRectMake(self.label6.frame.origin.x, self.label6.frame.origin.y-64, self.label6.frame.size.width, self.label6.frame.size.height)];
        [self.label7 setFrame:CGRectMake(self.label7.frame.origin.x, self.label7.frame.origin.y-64, self.label7.frame.size.width, self.label7.frame.size.height)];
        [self.label8 setFrame:CGRectMake(self.label8.frame.origin.x, self.label8.frame.origin.y-64, self.label8.frame.size.width, self.label8.frame.size.height)];
        [self.label9 setFrame:CGRectMake(self.label9.frame.origin.x, self.label9.frame.origin.y-64, self.label9.frame.size.width, self.label9.frame.size.height)];
        [self.label10 setFrame:CGRectMake(self.label10.frame.origin.x, self.label10.frame.origin.y-64, self.label10.frame.size.width, self.label10.frame.size.height)];
        [self.label11 setFrame:CGRectMake(self.label11.frame.origin.x, self.label11.frame.origin.y-64, self.label11.frame.size.width, self.label11.frame.size.height)];
        [self.typeBtn setFrame:CGRectMake(self.typeBtn.frame.origin.x, self.typeBtn.frame.origin.y-64, self.typeBtn.frame.size.width, self.typeBtn.frame.size.height)];
        [self.dateBtn setFrame:CGRectMake(self.dateBtn.frame.origin.x, self.dateBtn.frame.origin.y-64, self.dateBtn.frame.size.width, self.dateBtn.frame.size.height)];
        [self.supplierText setFrame:CGRectMake(self.supplierText.frame.origin.x, self.supplierText.frame.origin.y-64, self.supplierText.frame.size.width, self.supplierText.frame.size.height)];
        [self.supplierQuText setFrame:CGRectMake(self.supplierQuText.frame.origin.x, self.supplierQuText.frame.origin.y-64, self.supplierQuText.frame.size.width, self.supplierQuText.frame.size.height)];
        [self.purchaserText setFrame:CGRectMake(self.purchaserText.frame.origin.x, self.purchaserText.frame.origin.y-64, self.purchaserText.frame.size.width, self.purchaserText.frame.size.height)];
        [self.signerText setFrame:CGRectMake(self.signerText.frame.origin.x, self.signerText.frame.origin.y-64, self.signerText.frame.size.width, self.signerText.frame.size.height)];
        [self.priceText setFrame:CGRectMake(self.priceText.frame.origin.x, self.priceText.frame.origin.y-64, self.priceText.frame.size.width, self.priceText.frame.size.height)];
        [self.numText setFrame:CGRectMake(self.numText.frame.origin.x, self.numText.frame.origin.y-64, self.numText.frame.size.width, self.numText.frame.size.height)];
        [self.unitText setFrame:CGRectMake(self.unitText.frame.origin.x, self.unitText.frame.origin.y-64, self.unitText.frame.size.width, self.unitText.frame.size.height)];
        [self.totalPriceText setFrame:CGRectMake(self.totalPriceText.frame.origin.x, self.totalPriceText.frame.origin.y-64, self.totalPriceText.frame.size.width, self.totalPriceText.frame.size.height)];
        [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y-64, [UIScreen mainScreen].bounds.size.width-self.remarkText.frame.origin.x-8, self.remarkText.frame.size.height)];
        if (self.remarkText.frame.size.height + self.remarkText.frame.origin.y +64 > [UIScreen mainScreen].bounds.size.height) {
            [self.remarkText setFrame:CGRectMake(self.remarkText.frame.origin.x, self.remarkText.frame.origin.y, [UIScreen mainScreen].bounds.size.width-self.remarkText.frame.origin.x-8, [UIScreen mainScreen].bounds.size.height - self.remarkText.frame.origin.y-8 - 64)];
        }
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
