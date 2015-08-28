//
//  AddNoticeViewController.m
//  hmjs
//
//  Created by yons on 14-12-4.
//  Copyright (c) 2014年 yons. All rights reserved.
//

#import "AddNoticeViewController.h"
#import "MKNetworkKit.h"
#import "Utils.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UITextView+PlaceHolder.h"
#import "UIViewController+HUD.h"

@interface AddNoticeViewController (){
    MKNetworkEngine *engine;
    NSMutableArray *fileArr;
}

@property (nonatomic, strong) ALAssetsLibrary *specialLibrary;

@end

@implementation AddNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect rect = self.titleLabel.frame;
    rect.size.height = 40;
    self.titleLabel.frame = rect;
    //初始化引擎
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
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
    
    self.title = @"发布公告";
    
    //添加手势，点击输入框其他区域隐藏键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView =NO;
    [self.view addGestureRecognizer:tapGr];
    
//    [self.imagePickBtn setBackgroundImage:[UIImage imageNamed:@"smiley_add_btn_nor.png"] forState:UIControlStateNormal];
//    [self.imagePickBtn setImage:[UIImage imageNamed:@"smiley_add_btn_pressed.png"] forState:UIControlStateHighlighted];
    
    //添加按钮
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveData)];
    self.navigationItem.rightBarButtonItems = @[rightBtn];
    
    
    
    
    [self.myscrollview setContentSize:CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+1)];
    [self.myscrollview setScrollEnabled:YES];
    
    self.chosenImages = [[NSMutableArray alloc] init];
    //[self.myscrollview setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    fileArr = [[NSMutableArray alloc] init];
    
    [self.contentTextview addPlaceHolder:@"请填写内容"];
    
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



-(void)saveData{
    [self viewTapped:nil];
    if (self.titleLabel.text.length == 0) {
        [self showHint:@"请填写标题"];
    }else if(self.contentTextview.text.length == 0){
        [self showHint:@"请填写内容"];
    }else{
        [self showHudInView:self.view hint:@"加载中"];
        if (self.chosenImages.count == 0) {
            [self insertData];
        }else{
            [fileArr removeAllObjects];
            for (int i = 0 ; i < self.chosenImages.count; i++) {
                [self uploadImg:i];
            }
        }
    }
}

-(void)insertData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *userid = [userDefaults objectForKey:@"userid"];
    NSString *schoolid = [userDefaults objectForKey:@"schoolid"];
    
    [dic setValue:userid forKey:@"userid"];
    [dic setValue:schoolid forKey:@"schoolId"];
    [dic setValue:self.titleLabel.text forKey:@"noticetitle"];
    [dic setValue:self.contentTextview.text forKey:@"noticecontent"];
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
    
    MKNetworkOperation *op = [engine operationWithPath:@"/schoolNotice/save.do" params:dic httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        //        NSLog(@"[operation responseData]-->>%@", [operation responseString]);
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            [self hideHud];
            self.titleLabel.text = @"";
            self.contentTextview.text = @"";
            [self showHint:@"保存成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self hideHud];
            [self showHint:@"保存失败"];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
        [self hideHud];
    }];
    [engine enqueueOperation:op];
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
        NSString *msg = [resultDict objectForKey:@"msg"];
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
                [self insertData];
            }
        }else{
            [self hideHud];
            NSLog(@"上传失败 %@ %d",msg,num);
            [self showHint:@"上传失败"];
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
        [self hideHud];
        [self showHint:[err localizedDescription]];
    }];
    [engine enqueueOperation:op];
}

- (IBAction)launchController{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"选择照片", nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
}

- (void)reloadImageToView{
    
    NSTimeInterval animationDuration = 0.5f;
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
    
    if (self.chosenImages.count == 9) {
        [self.imagePickBtn setHidden:YES];
    }else{
        [self.imagePickBtn setHidden:NO];
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
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
