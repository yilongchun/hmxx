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
    
    NSString *schoolid;
    NSInteger selectedIndex;
}

@end

@implementation AddPuchaseViewController
@synthesize dataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"食品采购日报表";
    
    self.typeBtn.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.typeBtn.layer.borderWidth = 0.4f;
    self.typeBtn.layer.cornerRadius = 5.0f;
    
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
        [self alertWithPicer:currencyPicker];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择采购类型\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确定"
                                                        otherButtonTitles:nil, nil];
        [actionSheet addSubview:currencyPicker];
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
        NSDictionary *info = [dataSource objectAtIndex:selectedIndex];
        NSString *str = [info objectForKey:@"name"];
        [self.typeBtn setTitle:str forState:UIControlStateNormal];
    }
}

-(void)alertWithPicer:(UIPickerView *)picker
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"请选择采购类型\n\n\n\n\n\n\n\n\n\n"// change UIAlertController height
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
//    UIPickerView *ios8Picker = picker;
//    NSDictionary *info = [dataSource objectAtIndex:(long)ios8Picker.tag];
//    NSString *str = [info objectForKey:@"name"];
//    [self.typeBtn setTitle:str forState:UIControlStateNormal];
    
    //set the pickers selection indicator to true so that the user will now which one that they are chosing
    [picker setShowsSelectionIndicator:YES];
    
    //Add the picker to the alert controller
    [alert.view addSubview:picker];
    
//    //make the toolbar view
//    UIToolbar *toolView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width-16, kToolBarHeight)];
////    toolView.backgroundColor = [UIColor blackColor]; //set it's background
//    toolView.barStyle = UIBarStyleBlackTranslucent;
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, kToolBarHeight)];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.font = [UIFont systemFontOfSize:14];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    //    titleLabel.text = title;
//    UIBarButtonItem *bbtTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
//    UIBarButtonItem *bbtSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *bbtOK = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(OKWithPicker)];
//    bbtOK.width = 60.f;
//    UIBarButtonItem *bbtCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(CancleWithPicker)];
//    bbtCancel.width = 60.f;
//    toolView.items = [NSArray arrayWithObjects:bbtCancel,bbtSpace,bbtTitle,bbtSpace,bbtOK, nil];
    
//    [alert.view addSubview:toolView];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//-(void)OKWithPicker{
//    NSLog(@"ok");
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
//-(void)CancleWithPicker{
//    NSLog(@"cancel");
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

-(void)save{
    NSLog(@"save");
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
@end
