//
//  ViewController.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "KYFaceViewController.h"

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
  picker.allowsEditing = NO;//设置不可编辑（无编辑框模式）
  picker.navigationBar.barStyle = UIBarStyleDefault;
  picker.navigationBar.barTintColor = [UIColor whiteColor];
  picker.sourceType = sourceType;
  picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
  [self presentViewController:picker animated:YES completion:^{}];//进入照相界面
}


/**
 * @brief 获取图片
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  [picker dismissViewControllerAnimated:YES completion:^{}];
  UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
  
  _imageView.image = picture;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  //设置statusb的样式
  [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
  [picker dismissViewControllerAnimated:YES completion:^{}];
}


- (IBAction)onClickFaceDetect:(id)sender {
  
  KYFaceViewController *faceController = [[KYFaceViewController alloc] init];
   [[self navigationController] pushViewController:faceController animated:YES];
  
}

@end
