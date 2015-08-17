//
//  GgxqWebViewController.h
//  hmjz
//
//  Created by yons on 15-8-14.
//  Copyright (c) 2015年 yons. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GgxqWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property(nonatomic,copy) NSString *tnid;//公告id
@property int type;

@end
