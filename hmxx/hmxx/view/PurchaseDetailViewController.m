//
//  PurchaseDetailViewController.m
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PurchaseDetailViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"

@interface PurchaseDetailViewController (){
    MKNetworkEngine *engine;
    UIPickerView *currencyPicker;
    UIDatePicker *datePicker;
    
    NSString *schoolid;
    NSInteger selectedIndex;
}

@end

@implementation PurchaseDetailViewController
@synthesize info;
@synthesize myscrollview;
@synthesize dataSource;

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
    
    [self.myswitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    [self.typeBtn setBackgroundImage:[[UIImage imageNamed:@"grayBg.png"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [self.dateBtn setBackgroundImage:[[UIImage imageNamed:@"grayBg.png"]stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    
    
    [self showHudInView:self.view hint:@""];
    if (self.isShow) {
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                     target:self
                                     action:@selector(save)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    }else{
        [self.purchasetitle setUserInteractionEnabled:NO];
        [self.typeBtn setUserInteractionEnabled:NO];
        [self.dateBtn setUserInteractionEnabled:NO];
        [self.supplierText setUserInteractionEnabled:NO];
        [self.supplierQuText setUserInteractionEnabled:NO];
        [self.numText setUserInteractionEnabled:NO];
        [self.purchaserText setUserInteractionEnabled:NO];
        [self.signerText setUserInteractionEnabled:NO];
        [self.priceText setUserInteractionEnabled:NO];
        [self.unitText setUserInteractionEnabled:NO];
        [self.totalPriceText setUserInteractionEnabled:NO];
        [self.remarkText setUserInteractionEnabled:NO];
        [self.myswitch setUserInteractionEnabled:NO];
    }
    
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12.0f, 15.0f, self.view.frame.size.width-24, 210.0f)];
    currencyPicker.delegate = self;
    currencyPicker.dataSource = self;
    currencyPicker.showsSelectionIndicator = YES;
    
    datePicker = [ [ UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setMaximumDate:[NSDate date]];
//    [datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
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
    NSString *purchasetitle = [info objectForKey:@"title"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:purchaseDate];
    [datePicker setDate:date];
    
    self.purchasetitle.text = purchasetitle;
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
    
    [self loadData];
}

//加载数据
- (void)loadData{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    schoolid = [userDefaults objectForKey:@"schoolid"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:schoolid forKey:@"schoolId"];
    //    [dic setValue:classId forKey:@"classId"];
    MKNetworkOperation *op = [engine operationWithPath:@"/purchase/purchasetypeList.do" params:dic httpMethod:@"GET"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSArray *arr = [data objectForKey:@"rows"];
                dataSource = [NSMutableArray arrayWithArray:arr];
                [currencyPicker reloadAllComponents];
                
                NSString *purchase_type = [info objectForKey:@"purchase_type"];
                for (int i = 0 ; i < arr.count; i ++) {
                    NSDictionary *typeDic = [arr objectAtIndex:i];
                    NSString *typeId = [typeDic objectForKey:@"id"];
                    if ([typeId isEqualToString:purchase_type]) {
                        selectedIndex = i;
                        [currencyPicker selectRow:selectedIndex inComponent:0 animated:YES];
                    }
                }
                
            }
            [self hideHud];
        }else{
            [self hideHud];
            [self showHint:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        [self showHint:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

- (IBAction)chooseType:(id)sender {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        [self alertWithPicer:currencyPicker title:@"请选择采购类型"];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择采购类型\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确定"
                                                        otherButtonTitles:nil, nil];
        actionSheet.tag = 1;
        [actionSheet addSubview:currencyPicker];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)chooseDate:(id)sender {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"请选择日期\n\n\n\n\n\n\n\n\n\n"// change UIAlertController height
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSDate *date = datePicker.date;
                                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                    NSString *destDateString = [dateFormatter stringFromDate:date];
                                                    [self.dateBtn setTitle:destDateString forState:UIControlStateNormal];
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    
                                                }]];
        
        
        //Make a frame for the picker & then create the picker
        CGRect pickerFrame = CGRectMake(12, 15, self.view.frame.size.width-24-20, 216);
        datePicker.frame = pickerFrame;
        [alert.view addSubview:datePicker];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择日期\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确定"
                                                        otherButtonTitles:nil, nil];
        actionSheet.tag = 2;
        [actionSheet addSubview:datePicker];
        [actionSheet showInView:self.view];
    }
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [dataSource count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *dic = [dataSource objectAtIndex:row];
    NSString *str = [dic objectForKey:@"name"];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedIndex = row;
    NSDictionary *dic = [dataSource objectAtIndex:selectedIndex];
    NSString *str = [dic objectForKey:@"name"];
    [self.typeBtn setTitle:str forState:UIControlStateNormal];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == 1) {
            NSDictionary *dic = [dataSource objectAtIndex:selectedIndex];
            NSString *str = [dic objectForKey:@"name"];
            [self.typeBtn setTitle:str forState:UIControlStateNormal];
        }else if (actionSheet.tag == 2){
            NSDate *date = datePicker.date;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *destDateString = [dateFormatter stringFromDate:date];
            [self.dateBtn setTitle:destDateString forState:UIControlStateNormal];
        }
    }
}

-(void)alertWithPicer:(UIView *)picker title:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n\n",title]// change UIAlertController height
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                              style:UIAlertActionStyleDestructive
                                            handler:^(UIAlertAction *action) {
                                                NSDictionary *dic = [dataSource objectAtIndex:selectedIndex];
                                                NSString *str = [dic objectForKey:@"name"];
                                                [self.typeBtn setTitle:str forState:UIControlStateNormal];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
                                                
                                            }]];
    
    
    //Make a frame for the picker & then create the picker
    CGRect pickerFrame = CGRectMake(12, 15, self.view.frame.size.width-24-20, 216);
    picker.frame = pickerFrame;
    
    [alert.view addSubview:picker];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)save{
    
    if ([self.typeBtn.titleLabel.text isEqualToString:@"请选择采购类型"]) {
        [self showHint:@"请选择采购类型"];
        return;
    }
    if ([self.dateBtn.titleLabel.text isEqualToString:@"请选择日期"]) {
        [self showHint:@"请选择日期"];
        return;
    }
    if ([self.priceText.text isEqualToString:@""]) {
        [self showHint:@"请填写单价"];
        return;
    }
    if ([self.numText.text isEqualToString:@""]) {
        [self showHint:@"请填写数量"];
        return;
    }
    
    
    [self showHudInView:self.view hint:@""];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    NSString *detailId = [info objectForKey:@"id"];
    
    NSDictionary *dic2 = [self.dataSource objectAtIndex:selectedIndex];
    NSString *purchase_type = [dic2 objectForKey:@"id"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:detailId forKey:@"id"];
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:self.purchasetitle.text forKey:@"title"];
    [dic setValue:purchase_type forKey:@"purchaseType"];//采购类型
    [dic setValue:self.dateBtn.titleLabel.text forKey:@"purchaseDate"];//日期
    [dic setValue:self.supplierText.text forKey:@"supplier"];//供货单位
    [dic setValue:self.supplierQuText.text forKey:@"supplierQu"];//资质
    [dic setValue:self.numText.text forKey:@"num"];//数量
    [dic setValue:self.purchaserText.text forKey:@"purchaser"];//采购人
    [dic setValue:self.signerText.text forKey:@"signer"];//签收人
    [dic setValue:self.priceText.text forKey:@"price"];//单价
    [dic setValue:self.totalPriceText.text forKey:@"totalPrice"];//总价
    [dic setValue:self.unitText.text forKey:@"unit"];//单位
    if (self.myswitch.isOn) {
        [dic setValue:@"1"  forKey:@"hasReceipt"];//索票
    }else{
        [dic setValue:@"0"  forKey:@"hasReceipt"];//索票
    }
    [dic setValue:self.remarkText.text forKey:@"remark"];//备注
    
    MKNetworkOperation *op = [engine operationWithPath:@"/purchase/update.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            [self hideHud];
            UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            [self showHint:msg customView:imageview];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.0f];
        }else{
            [self hideHud];
            [self showHint:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
        [self showHint:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchaseType" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchaseTypeDetail" object:nil];
}


-(void)textFieldDidEndEditing:( UITextField *)textField{
    if (textField.tag == 10 || textField.tag == 11) {
        int num = [self.numText.text intValue];
        double price = [self.priceText.text doubleValue];
        double total = num * price;
        self.totalPriceText.text = [NSString stringWithFormat:@"%.2f",total];
    }
}

-(void)switchAction:(UISwitch *)sender{
    BOOL isOn = [sender isOn];
    if (isOn) {
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
