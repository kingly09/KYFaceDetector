//
//  ViewController.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "KYFaceViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,KYFaceViewControllerDelegate> {
  
  UIImage *currImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *zjImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSelfPortraits:(id)sender {
  
  [self openCamera];
  
}

/**
 * @brief 打开相机
 */
-(void)openCamera
{
  //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
  UIImagePickerControllerSourceType sourceType;
  if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//图片库
  }else{
    sourceType = UIImagePickerControllerSourceTypeCamera;//照相机
  }
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
  picker.delegate = self;
  picker.allowsEditing = YES;//设置不可编辑（无编辑框模式）
  picker.navigationBar.barStyle = UIBarStyleDefault;
  picker.navigationBar.barTintColor = [UIColor whiteColor];
  picker.sourceType = sourceType;
  picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;  //默认前置摄像头
  [self presentViewController:picker animated:YES completion:^{}]; //进入照相界面
  
}


/**
 * @brief 获取图片
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  [picker dismissViewControllerAnimated:YES completion:^{}];
  UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
  
  currImage = picture;
  
  _imageView.image = picture;
}




- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  //设置statusb的样式
  [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
  [picker dismissViewControllerAnimated:YES completion:^{}];
  
}


- (IBAction)onClickFaceDetect:(id)sender {
  
  
  if (currImage == nil) {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先拍一张人脸图，再点击人脸识别" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    return;
  }
  
  KYFaceViewController *faceController = [[KYFaceViewController alloc] init];
  faceController.delegate = self;
  faceController.comparedPicture = _imageView.image;
  [[self navigationController] pushViewController:faceController animated:YES];
  
}

#pragma mark - KYFaceViewControllerDelegate
/**
 人脸比对结果
 
 @param faceDetectionState 人脸比对的状态
 @param currImage  当前获取的人脸头像
 @param detectionError 人脸比对错误信息
 */
- (void)faceDetection:(KYFaceDetectionState )faceDetectionState
        withCurrImage:(UIImage *)currImage
            withError:(NSError *)detectionError {
  
  
  if (faceDetectionState == KYFaceDetectionStateSuccess) {
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:@"人脸比对成功"
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil,nil];
//    [alert show];
    
    _zjImageView.image = currImage;
    
  }else{
    
     _zjImageView.image = nil;
  }
  
}

@end
