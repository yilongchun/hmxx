//
//  JsfcDetailViewController.m
//  hmxx
//
//  Created by yons on 15-1-23.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "JsfcDetailViewController.h"
#import "Utils.h"
#import "MKNetworkKit.h"
#import "UIImageView+AFNetworking.h"

@interface JsfcDetailViewController (){
    MKNetworkEngine *engine;
    
    NSString *teacherId;
    NSString *imageid;
}

@end

@implementation JsfcDetailViewController
@synthesize detailId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    engine = [[MKNetworkEngine alloc] initWithHostName:[Utils getHostname] customHeaderFields:nil];
    
    self.title = @"教师信息";
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *userdata = [userdefault objectForKey:@"user"];
    NSNumber *roletype = [userdata objectForKey:@"roletype"];
    
    if ([roletype intValue] == 2) {
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateImgAction:)];
        [self.userimage addGestureRecognizer:singleTap1];
    }
    
    [self loadData];
}

-(void)loadData{
    [self showHudInView:self.view hint:@""];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:detailId forKey:@"id"];
    MKNetworkOperation *op = [engine operationWithPath:@"/teacherelegant/findById.do" params:dic httpMethod:@"GET"];
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
            NSDictionary *data = [resultDict objectForKey:@"data"];
            if (data != nil) {
                NSString *teacherName = [data objectForKey:@"teacherName"];
                NSString *flieid = [data objectForKey:@"flieid"];
                imageid = [data objectForKey:@"imageid"];
                NSArray *classList = [data objectForKey:@"classList"];
                NSDictionary *classDic = [classList objectAtIndex:0];
                NSNumber *ishead = [classDic objectForKey:@"ishead"];
                teacherId = [data objectForKey:@"userId"];
                self.username.text = [NSString stringWithFormat:@"%@",teacherName];
                if ([Utils isBlankString:flieid]) {
                    [self.userimage setImage:[UIImage imageNamed:@"nopicture2.png"]];
                }else{
                    [self.userimage setImageWithURL:[NSURL URLWithString:flieid] placeholderImage:[UIImage imageNamed:@"nopicture2.png"]];
                }
                if ([ishead boolValue]) {
                    self.userjob.text = [NSString stringWithFormat:@"%@",@"班主任"];
                }else{
                    self.userjob.text = [NSString stringWithFormat:@"%@",@"教师"];
                }
                [self hideHud];
            }
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

//点击头像 修改照片
- (void)updateImgAction:(UITapGestureRecognizer *)sender{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
    [actionsheet showInView:self.view];
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
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
            //            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
            
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
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
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *fildData = UIImageJPEGRepresentation(img, 0.5);//UIImagePNGRepresentation(img); //
        [self uploadImg:fildData];
        //        self.fileData = UIImageJPEGRepresentation(img, 1.0);
    }
    //    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"kUTTypeMovie"]) {
    //        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    //        self.fileData = [NSData dataWithContentsOfFile:videoPath];
    //    }
    [picker dismissViewControllerAnimated:YES completion:^{
        [self showHudInView:self.view hint:@""];
        
    }];
}
//上传图片
-(void)uploadImg:(NSData *)fileData{
    
    //将文件保存到本地
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.jpg"];
    BOOL saveFlag = [fileData writeToFile:savedImagePath atomically:YES];
    
    MKNetworkOperation *op =[engine operationWithURLString:[NSString stringWithFormat:@"http://%@/image/upload.do",[Utils getImageHostname]] params:nil httpMethod:@"POST"];
    [op addFile:savedImagePath forKey:@"allFile"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSString *result = [operation responseString];
        NSError *error;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (resultDict == nil) {
            NSLog(@"json parse failed \r\n");
        }
        NSNumber *success = [resultDict objectForKey:@"success"];
        if ([success boolValue]) {
            //上传成功 删除文件  还有返回的问题
            [self updateImgData:[resultDict objectForKey:@"data"]];
        }else{
            [self showHint:@"上传失败"];
        }
        if (saveFlag) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSError *err;
            [fileMgr removeItemAtPath:savedImagePath error:&err];
        }
    }errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"MKNetwork request error : %@", [err localizedDescription]);
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
//修改数据
- (void)updateImgData:(NSString *)fileid{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:teacherId forKey:@"userid"];
    [dic setValue:fileid forKey:@"fileid"];//新图片的
    [dic setValue:imageid forKey:@"imageid"];
    MKNetworkOperation *op = [engine operationWithPath:@"/Teacher/updatereleimage.do" params:dic httpMethod:@"POST"];
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
            [self.userimage setImageWithURL:[NSURL URLWithString:fileid]];
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


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)backAndReload{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadJsfc" object:nil];
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
