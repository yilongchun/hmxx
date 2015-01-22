//
//  AddPuchaseViewController.m
//  hmxx
//
//  Created by yons on 15-1-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "AddPuchaseViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"


@interface AddPuchaseViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    MKNetworkEngine *engine;
    UIPickerView *currencyPicker;
    UIDatePicker *datePicker;
    
    NSString *schoolid;
    NSInteger selectedIndex;
}

@end

@implementation AddPuchaseViewController
@synthesize dataSource;
@synthesize myscrollview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"食品采购日报表";

    [myscrollview setContentSize:CGSizeMake(self.view.frame.size.width, 560)];
    
    self.typeBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.typeBtn.layer.borderWidth = 0.4f;
    self.typeBtn.layer.cornerRadius = 5.0f;
    
    
//    CGSize imageSize = CGSizeMake(self.typeBtn.frame.size.width, self.typeBtn.frame.size.height);
//    UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
//    [[UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1] set];
//    UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
//    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [self.typeBtn setImage:pressedColorImg forState:UIControlStateHighlighted];
    
    [self.myswitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
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
    
    
    
    
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
//    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
//    tapGr.cancelsTouchesInView =NO;
//    [self.view addGestureRecognizer:tapGr];
    
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];

    currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12.0f, 15.0f, self.view.frame.size.width-24, 210.0f)];
    currencyPicker.delegate = self;
    currencyPicker.dataSource = self;
    currencyPicker.showsSelectionIndicator = YES;
    
    datePicker = [ [ UIDatePicker alloc] initWithFrame:CGRectMake(0, 15, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
    
    [self loadData];
    selectedIndex = 0;
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
            }
            [HUD hide:YES];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接失败"];
    }];
    [engine enqueueOperation:op];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    NSDictionary *info = [dataSource objectAtIndex:row];
    NSString *str = [info objectForKey:@"name"];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedIndex = row;
    NSDictionary *info = [dataSource objectAtIndex:selectedIndex];
    NSString *str = [info objectForKey:@"name"];
    [self.typeBtn setTitle:str forState:UIControlStateNormal];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == 1) {
            NSDictionary *info = [dataSource objectAtIndex:selectedIndex];
            NSString *str = [info objectForKey:@"name"];
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
                                                NSDictionary *info = [dataSource objectAtIndex:selectedIndex];
                                                NSString *str = [info objectForKey:@"name"];
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
        [self alertMsg:@"请选择采购类型"];
        return;
    }
    if ([self.dateBtn.titleLabel.text isEqualToString:@"请选择日期"]) {
        [self alertMsg:@"请选择日期"];
        return;
    }
    if ([self.priceText.text isEqualToString:@""]) {
        [self alertMsg:@"请填写单价"];
        return;
    }
    if ([self.numText.text isEqualToString:@""]) {
        [self alertMsg:@"请填写数量"];
        return;
    }
    
    
    [HUD show:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userid = [userDefaults objectForKey:@"userid"];
    NSDictionary *info = [self.dataSource objectAtIndex:selectedIndex];
    NSString *purchase_type = [info objectForKey:@"id"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:purchase_type forKey:@"purchaseType"];//采购类型
    [dic setValue:self.dateBtn.titleLabel.text forKey:@"purchaseDate"];//日期
    [dic setValue:self.supplierText.text == nil ? @"" : self.supplierText.text forKey:@"supplier"];//供货单位
    [dic setValue:self.supplierQuText.text == nil ? @"" : self.supplierQuText.text forKey:@"supplierQu"];//资质
    [dic setValue:self.numText.text forKey:@"num"];//数量
    [dic setValue:self.purchaserText.text == nil ? @"" : self.purchaserText.text forKey:@"purchaser"];//采购人
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
    
    MKNetworkOperation *op = [engine operationWithPath:@"/purchase/save.do" params:dic httpMethod:@"POST"];
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
            [HUD hide:YES];
            [self okMsk:msg];
            [self performSelector:@selector(backAndReload) withObject:nil afterDelay:1.5f];
        }else{
            [HUD hide:YES];
            [self alertMsg:msg];
            
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接失败"];
    }];
    [engine enqueueOperation:op];
}

//成功
- (void)okMsk:(NSString *)msg{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.delegate = self;
    hud.labelText = msg;
    [hud show:YES];
    [hud hide:YES afterDelay:1.5];
}

//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.5];
}

-(void)backAndReload{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchase" object:nil];
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


@end
