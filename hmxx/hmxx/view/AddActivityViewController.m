//
//  AddActivityViewController.m
//  hmjs
//
//  Created by yons on 14-12-5.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AddActivityViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "UITextView+PlaceHolder.h"

@interface AddActivityViewController ()<MBProgressHUDDelegate>{
    MKNetworkEngine *engine;
    MBProgressHUD *HUD;
    int type;
    NSMutableArray *fileArr;
    NSURL *videoUrl;
    BOOL flag;
}

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation AddActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentTextview addPlaceHolder:@"请填写内容"];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = self.titleLabel.frame;
    rect.size.height = 40;
    self.titleLabel.frame = rect;
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    //添加加载等待条
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"加载中...";
    [self.view addSubview:HUD];
    HUD.delegate = self;
    
    self.contentTextview.layer.borderColor = [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1].CGColor;
    self.contentTextview.layer.borderWidth = 1.0;
    self.contentTextview.layer.cornerRadius = 5.0f;
    //    _textView.delegate = self;
    //    _textView.scrollEnabled = YES;
    //    self.contentTextview.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    //    _textView.returnKeyType = UIReturnKeyDefault;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        //        self.contentTextview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        //        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self.contentTextview.layer setMasksToBounds:YES];
    
    self.view.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1];
    
    
    
    self.title = @"发布活动";
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
//    [self.imagePickBtn setBackgroundImage:[UIImage imageNamed:@"smiley_add_btn_nor.png"] forState:UIControlStateNormal];
//    [self.imagePickBtn setImage:[UIImage imageNamed:@"smiley_add_btn_pressed.png"] forState:UIControlStateHighlighted];
    
    //添加按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+1)];
    [self.myscrollview setScrollEnabled:YES];
    
    self.chosenImages = [[NSMutableArray alloc] init];
    //[self.myscrollview setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    fileArr = [[NSMutableArray alloc] init];
    
    
}

//隐藏键盘
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.titleLabel resignFirstResponder];
    [self.contentTextview resignFirstResponder];
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

- (void)save{
    [self viewTapped:nil];
    if (self.titleLabel.text.length == 0) {
        [self alertMsg:@"请填写标题"];
    }else if(self.contentTextview.text.length == 0){
        [self alertMsg:@"请填写内容"];
    }else{
        [HUD show:YES];
        if (self.chosenImages.count == 0) {
            flag = true;
            [self insertData];
        }else{
            flag = false;
            if (type == 1) {
                [fileArr removeAllObjects];
                for (int i = 0 ; i < self.chosenImages.count; i++) {
                    [self uploadImg:i];
                }
            }else if(type == 2){
                [self uploadVideo];
            }
            
        }
    }
}

-(void)insertData{
    
    if (flag) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:self.titleLabel.text forKey:@"activityTitle"];
        [dic setValue:self.contentTextview.text forKey:@"activityContent"];
        [dic setValue:[userDefaults objectForKey:@"userid"] forKey:@"userid"];
        [dic setValue:schoolid forKey:@"schoolId"];
        if (type == 1) {
            [dic setValue:@"image" forKey:@"filetype"];
        }else if(type == 2){
            [dic setValue:@"video" forKey:@"filetype"];
        }else if(self.chosenImages.count == 0){
            [dic setValue:@"" forKey:@"filetype"];
        }
        
        if (fileArr.count !=0 && fileArr.count == self.chosenImages.count) {
            NSMutableString *fileids = [[NSMutableString alloc] init];
            for (int i = 0 ; i < fileArr.count; i++) {
                NSString *fileid = [fileArr objectAtIndex:i];
                [fileids appendString:fileid];
                if (i < fileArr.count -1) {
                    [fileids appendString:@","];
                }
            }
            [dic setValue:fileids forKey:@"fileid"];
        }else{
            [dic setValue:@"" forKey:@"fileid"];
        }
        
        MKNetworkOperation *op = [engine operationWithPath:@"/SchoolActivity/save.do" params:dic httpMethod:@"POST"];
        [op addCompletionHandler:^(MKNetworkOperation *operation) {
            NSLog(@"[operation responseData]-->>%@", [operation responseString]);
            NSString *result = [operation responseString];
            NSError *error;
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (resultDict == nil) {
                NSLog(@"json parse failed \r\n");
            }
            NSNumber *success = [resultDict objectForKey:@"success"];
            NSString *msg = [resultDict objectForKey:@"msg"];
            //        NSString *code = [resultDict objectForKey:@"code"];
            if ([success boolValue]) {
                //            NSDictionary *data = [resultDict objectForKey:@"data"];
                [HUD hide:YES];
                [self alertMsg:msg];
                self.titleLabel.text = @"";
                self.contentTextview.text = @"";
                [self.chosenImages removeAllObjects];
                [fileArr removeAllObjects];
                [self reloadImageToView];
                
                
            }else{
                [HUD hide:YES];
                [self alertMsg:msg];
            }
        }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
            NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
            [HUD hide:YES];
            [self alertMsg:@"连接服务器失败"];
        }];
        [engine enqueueOperation:op];
    }else{
        
    }
    
}


//上传图片
-(void)uploadImg:(int)num{
    
//    __weak AddActivityViewController *weakSelf = self;
    
    
    UIImage *image = [self.chosenImages objectAtIndex:num];
    NSData *fileData = UIImageJPEGRepresentation(image, 0.5);
    
    //将文件保存到本地
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg",num]];
    BOOL saveFlag = [fileData writeToFile:savedImagePath atomically:YES];
    
    MKNetworkOperation *op =[engine operationWithURLString:[NSString stringWithFormat:@"http://%@/image/upload.do",[Utils getImageHostname]] params:nil httpMethod:@"POST"];
    
    [op addFile:savedImagePath forKey:@"allFile"];
    [op setFreezable:NO];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
//        NSString *msg = [resultDict objectForKey:@"msg"];
        if ([success boolValue]) {
            NSString *fileurl = [resultDict objectForKey:@"data"];
            [fileArr addObject:fileurl];
            NSLog(@"上传成功 %d",num);
//            if (num + 1 < self.chosenImages.count) {
//                [weakSelf uploadImg:num + 1];
//            }else{
//                flag = true;
//                [self insertData];
//            }
            
            if (fileArr.count == self.chosenImages.count) {
                flag = true;
                [self insertData];
            }
        }else{
            flag = false;
            [HUD hide:YES];
//            NSLog(@"上传失败 %@ %d",msg,num);
            [self alertMsg:@"上传失败"];
        }
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        NSLog(@"%@ %d",[err localizedDescription],num);
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
        [HUD hide:YES];
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
}
//上传视频
-(void)uploadVideo{
    
    NSData *filedata = [NSData dataWithContentsOfURL:videoUrl];
    
//    NSString *thePath=[[NSBundle mainBundle] pathForResource:@"" ofType:@"mov"];
    
    MKNetworkOperation *op =[engine operationWithURLString:[NSString stringWithFormat:@"http://%@",[Utils getVideoHostname]] params:nil httpMethod:@"POST"];
//    [op addFile:videoUrl forKey:@"allFile"];
//   [op addData:filedata forKey:@"allFile"];
    [op addData:filedata forKey:@"allFile" mimeType:@"video/mov" fileName:@"output.mov"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = [operation responseString];NSLog(@"%@",result);
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            flag = true;
            NSString *fileurl = [resultDict objectForKey:@"data"];
            [fileArr addObject:fileurl];
            [self insertData];
        }else{
            flag = false;
            [HUD hide:YES];
            [self alertMsg:@"上传失败"];
        }
        if (flag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            BOOL b = [fileMgr removeItemAtPath:[videoUrl absoluteString] error:&err];
            if (!b) {
                NSLog(@"删除视频失败");
            }else{
                NSLog(@"删除视频成功");
            }
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [HUD hide:YES];
        [self alertMsg:@"连接服务器失败"];
    }];
    [engine enqueueOperation:op];
    
    
}

- (IBAction)launchController{
    if (self.chosenImages.count > 0 && type == 1) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片", nil];
        actionsheet.tag = 1;
        [actionsheet showInView:self.view];
    }else{
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片",@"录像",@"选择视频", nil];
        actionsheet.tag = 2;
        [actionsheet showInView:self.view];
    }
    
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
    [hud hide:YES afterDelay:1.0];
}


//提示
- (void)alertMsg:(NSString *)msg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

- (void)reloadImageToView{
    
    NSTimeInterval animationDuration = 1.0f;
    [UIView beginAnimations:@"ReloadImage" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    for (UIView *v in [self.myscrollview subviews]) {
        if ([v isKindOfClass:[UIButton class]]) {
            if (v.tag != 99) {
                [v removeFromSuperview];
            }
        }
    }
    
    
    CGRect workingFrame = CGRectMake(15, 220, 90, 90);
    
    for (int i = 0 ; i < self.chosenImages.count; i++) {
        UIImage *tempimage = [self.chosenImages objectAtIndex:i];
        
        if (i != 0 ) {
            if (i % 3 == 0) {
                workingFrame.origin.x = 15;
                workingFrame.origin.y += 100;
            }else{
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width + 10;
            }
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:workingFrame];
        btn.tag = i;
        [btn setImage:tempimage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.myscrollview addSubview:btn];
        
        
        
        
        if (i == self.chosenImages.count-1) {
            if ((i+1) % 3 == 0) {
                workingFrame.origin.x = 15;
                workingFrame.origin.y += 100;
            }else{
                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width + 10;
            }
        }
        
    }
    [self.imagePickBtn setFrame:workingFrame];
    
    if (type == 1) {
        if (self.chosenImages.count == 9) {
            [self.imagePickBtn setHidden:YES];
        }else{
            [self.imagePickBtn setHidden:NO];
        }
    }else if(type == 2){
        if (self.chosenImages.count == 1) {
            [self.imagePickBtn setHidden:YES];
        }else{
            [self.imagePickBtn setHidden:NO];
        }
    }
    
    
    [UIView commitAnimations];
    
//    if (self.imagePickBtn.hidden) {
//        UIButton *lastBtn = self.myscrollview.subviews.lastObject;
//        [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,lastBtn.frame.origin.y + lastBtn.frame.size.height + 10)];
//    }else{
//        [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.imagePickBtn.frame.origin.y + self.imagePickBtn.frame.size.height + 10)];
//    }
    
}

- (void)btnclick:(UIButton *)sender {
    [sender removeFromSuperview];
    [self.chosenImages removeObject:sender.imageView.image];
    [self reloadImageToView];
    if (type == 2) {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *err;
        NSMutableString *mstr = [[NSMutableString alloc] initWithString:[videoUrl absoluteString]];
        NSString *str = @"/var";
        //在str1这个字符串中搜索\n，判断有没有
        if ([mstr rangeOfString:str].location != NSNotFound) {
            NSString *filepath = [mstr substringFromIndex:[mstr rangeOfString:str].location];
            [fileMgr removeItemAtPath:filepath error:&err];
//            NSLog(@"%@ %@",b ? @"删除视频成功" : @"删除视频失败",videoUrl);
        }
    }
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
//    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                [images addObject:image];
                [self.chosenImages addObject:image];
                
                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
                
//                UIImageView *imageview = [[UIImageView alloc] initWithFrame:workingFrame];
//                imageview.image = image;
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
////                imageview.frame = workingFrame;
//                [self.view addSubview:imageview];
                
//                UIButton *btn = [[UIButton alloc] initWithFrame:workingFrame];
////                [btn setBackgroundImage:image forState:UIControlStateNormal];
//                btn.tag = self.chosenImages.count - 1;
//                [btn setImage:image forState:UIControlStateNormal];
//                [self.myscrollview addSubview:btn];
                
                
                
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
//            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
//                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                
//                [images addObject:image];
//                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
////                imageview.frame = workingFrame;
//                
////                [_scrollView addSubview:imageview];
//                
////                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
//            } else {
//                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
//            }
        } else {
            NSLog(@"Uknown asset type");
        }
    }
//    NSLog(@"%@",images);
//    [self.chosenImages addObjectsFromArray:[images copy]];
    [self reloadImageToView];
//    [_scrollView setPagingEnabled:YES];
//    [_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://照相机
        {
            type = 1;
            //检查相机模式是否可用
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSLog(@"sorry, no camera or camera is unavailable.");
                return;
            }
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes =  @[(NSString *)kUTTypeImage];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            type = 1;
            ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
            elcPicker.maximumImagesCount = 9 - self.chosenImages.count; //Set the maximum number of images to select to 100
            elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
            elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
            elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
            elcPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
            elcPicker.imagePickerDelegate = self;
            [self presentViewController:elcPicker animated:YES completion:nil];
        }
            break;
        case 2://录像
        {
            if(actionSheet.tag == 2){
                type = 2;
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    NSLog(@"sorry, no camera or camera is unavailable.");
                    return;
                }
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }
            break;
        case 3://选择视频
        {
            if(actionSheet.tag == 2){
                type = 2;
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker.mediaTypes =  @[(NSString *)kUTTypeMovie];
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage  *image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.chosenImages addObject:image];
        [self reloadImageToView];
    }
    else if([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        videoUrl = videoURL;
        NSLog(@"found a video %@",videoURL);
        //获取视频的thumbnail
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
        UIImage  *image = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        [self.chosenImages addObject:image];
        [self reloadImageToView];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
