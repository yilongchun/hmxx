//
//  MyTabbarController5.m
//  hmxx
//
//  Created by yons on 15-1-24.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyTabbarController5.h"
#import "XscqtjViewController.h"
#import "PurchaseReportViewController.h"

@interface MyTabbarController5 (){
    UIBarButtonItem *rightButton;
    NSString *year;
    PurchaseReportViewController *vc2;
    UIPickerView *currencyPicker;
    NSMutableArray *dataSource;
    NSInteger selectedIndex;
}

@end

@implementation MyTabbarController5

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    }
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    year = [NSString stringWithFormat:@"%d",[components year]];
    
    currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12.0f, 30.0f, self.view.frame.size.width-24, 210.0f)];
    currencyPicker.delegate = self;
    currencyPicker.dataSource = self;
    currencyPicker.showsSelectionIndicator = YES;
    dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i<200; i++) {
        int y = 1900 + i;
        [dataSource addObject:[NSString stringWithFormat:@"%d",y]];
        if ([[NSString stringWithFormat:@"%d",y] isEqualToString:year]) {
            selectedIndex = i;
        }
    }
    [currencyPicker selectRow:selectedIndex inComponent:0 animated:YES];
    
    UIImage *img1 = [UIImage imageNamed:@""];
    UIImage *img1_h = [UIImage imageNamed:@""];
    
    UIImage *img2 = [UIImage imageNamed:@""];
    UIImage *img2_h = [UIImage imageNamed:@""];
    
    XscqtjViewController *vc1 = [[XscqtjViewController alloc] init];
    vc2 = [[PurchaseReportViewController alloc] init];
    vc2.year = year;
    
    rightButton = [[UIBarButtonItem alloc]
                   initWithTitle:[NSString stringWithFormat:@"%@年",year]
                   style:UIBarButtonItemStyleBordered
                   target:self
                   action:@selector(chooseYear)];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        
        img1 = [img1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img1_h = [img1_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2 = [img2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        img2_h = [img2_h imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"学生出勤统计" image:img1 selectedImage:img1_h];
        [item1 setTag:0];
        vc1.tabBarItem = item1;
        
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"采购统计" image:img2 selectedImage:img2_h];
        [item2 setTag:1];
        vc2.tabBarItem = item2;
    }else{
        UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"学生出勤统计" image:img1 tag:0];
        vc1.tabBarItem = item1;
        UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"采购统计" image:img2 tag:1];
        vc2.tabBarItem = item2;
    }
    
    //    把导航控制器加入到数组
    NSMutableArray *viewArr_ = [NSMutableArray arrayWithObjects:vc1,vc2, nil];
    
    self.title = @"学生出勤统计";
    self.viewControllers = viewArr_;
    
    self.selectedIndex = 0;
    [[self tabBar] setSelectedImageTintColor:[UIColor colorWithRed:116/255.0 green:176/255.0 blue:64/255.0 alpha:1]];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = @"学生出勤统计";
        self.navigationItem.rightBarButtonItem = nil;
    }else if (item.tag == 1){
        self.title = @"采购统计";
        self.navigationItem.rightBarButtonItem = rightButton;
    }
}

-(void)chooseYear{
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:@"请选择年份\n\n\n\n\n\n\n\n\n\n\n"// change UIAlertController height
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction *action) {
                                                    NSString *s = [dataSource objectAtIndex:selectedIndex];
                                                    self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%@年",s];
                                                    vc2.year = s;
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchaseReport" object:nil];
                                                    
                                                }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                }]];
        CGRect pickerFrame = CGRectMake(12, 30, self.view.frame.size.width-24-16, 230);
        currencyPicker.frame = pickerFrame;
        [alert.view addSubview:currencyPicker];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择年份\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确定"
                                                        otherButtonTitles:nil, nil];
        actionSheet.tag = 2;
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
    NSString *s = [dataSource objectAtIndex:row];
    s = [NSString stringWithFormat:@"%@年",s];
    return s;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedIndex = row;
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (actionSheet.tag == 2){
            NSString *s = [dataSource objectAtIndex:selectedIndex];
            self.navigationItem.rightBarButtonItem.title = [NSString stringWithFormat:@"%@年",s];
            vc2.year = s;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPurchaseReport" object:nil];
        }
    }
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

@end
