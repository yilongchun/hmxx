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
    }
    NSString *typeName = [info objectForKey:@"typeName"];
    NSString *supplier = [info objectForKey:@"supplier"];
    NSString *supplierQu = [info objectForKey:@"supplierQu"];
    NSNumber *num = [info objectForKey:@"num"];
    NSString *purchaser = [info objectForKey:@"purchaser"];
    NSString *signer = [info objectForKey:@"signer"];
    NSNumber *totalPrice = [info objectForKey:@"totalPrice"];
 
    [self.typeBtn setTitle:typeName forState:UIControlStateNormal];
    self.text1.text = supplier;
    self.text2.text = supplierQu;
    self.text3.text = [NSString stringWithFormat:@"%d",[num intValue]];
    self.text4.text = purchaser;
    self.text5.text = signer;
    self.text7.text = [NSString stringWithFormat:@"%.2f",[totalPrice doubleValue]];
    
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
