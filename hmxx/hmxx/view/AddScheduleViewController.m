//
//  AddScheduleViewController.m
//  hmxx
//
//  Created by yons on 15-1-20.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "AddScheduleViewController.h"

@interface AddScheduleViewController ()

@end

@implementation AddScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"新增日志";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        self.mytextview.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self.mytextview setFrame:CGRectMake(self.mytextview.frame.origin.x, self.mytextview.frame.origin.y, [UIScreen mainScreen].bounds.size.width-8-85, self.mytextview.frame.size.height)];
    }else{
        [self.label1 setFrame:CGRectMake(self.label1.frame.origin.x, self.label1.frame.origin.y-55, self.label1.frame.size.width, self.label1.frame.size.height)];
        [self.label2 setFrame:CGRectMake(self.label2.frame.origin.x, self.label2.frame.origin.y-44, self.label2.frame.size.width, self.label2.frame.size.height)];
        [self.label3 setFrame:CGRectMake(self.label3.frame.origin.x, self.label3.frame.origin.y-44, self.label3.frame.size.width, self.label3.frame.size.height)];
        [self.scheduleTypeSegmented setFrame:CGRectMake(self.scheduleTypeSegmented.frame.origin.x, self.scheduleTypeSegmented.frame.origin.y-64, self.scheduleTypeSegmented.frame.size.width, self.scheduleTypeSegmented.frame.size.height)];
        [self.titleText setFrame:CGRectMake(self.titleText.frame.origin.x, self.titleText.frame.origin.y-44, self.titleText.frame.size.width, self.titleText.frame.size.height)];
        [self.mytextview setFrame:CGRectMake(self.mytextview.frame.origin.x, self.mytextview.frame.origin.y-44, self.mytextview.frame.size.width, self.mytextview.frame.size.height)];
    }
    
    self.mytextview.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.mytextview.layer.borderColor = [UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1].CGColor;
    self.mytextview.layer.borderWidth = 0.5;
    self.mytextview.layer.cornerRadius = 5.0f;
    self.mytextview.autoresizingMask = UIViewAutoresizingNone;
    self.mytextview.scrollEnabled = YES;
    self.mytextview.returnKeyType = UIReturnKeyDefault;
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    self.mytextview.backgroundColor = [UIColor whiteColor];
    [self.mytextview.layer setMasksToBounds:YES];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"保存"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

-(void)save{
    NSLog(@"save");
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
