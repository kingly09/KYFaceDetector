//
//  KYFaceViewController.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceViewController.h"
#import "AppDelegate.h"

#import <AVFoundation/AVFoundation.h>
#import <FDFramework/FaceDetector.h>

#import "KYFaceAnimationView.h"
#import "KYFaceDetectorErrorView.h"

#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

@interface KYFaceViewController ()<FaceDetectorDelegate,KYFaceDetectorErrorViewDelegate> {
  
  
  AVCaptureSession *session;
  AVCaptureVideoPreviewLayer *previewLayer;
  dispatch_queue_t queueOutput;
  dispatch_queue_t queueMeta;
  
  FaceDetector *faceDetector;
  
  KYFaceAnimationView *faceAnimationView;
  
  UIImage *currImage;
  
  UIScrollView *myScrollView;  //滚动视图
  UIView *leftView;            //左边视图
  KYFaceDetectorErrorView *faceDetectorErrorView;
  
}

// 取消认证
@property (nonatomic) UIBarButtonItem *cancelButtonItem;

@end

@implementation KYFaceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"人脸识别";
  [self.navigationItem setHidesBackButton:YES];
  [self.navigationItem setRightBarButtonItems:@[self.cancelButtonItem]];
  
  // get the face detector reference
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  faceDetector = [delegate faceDetector];
  [faceDetector setDelegate:self];
  
  
  //滚动视图
  myScrollView = [[UIScrollView alloc]init];
  myScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
  myScrollView.userInteractionEnabled = YES;
  myScrollView.showsHorizontalScrollIndicator = NO;
  myScrollView.showsVerticalScrollIndicator = NO;
  myScrollView.scrollEnabled = NO;
  myScrollView.contentSize = CGSizeMake(KScreenWidth * 2, KScreenHeight);
  [self.view addSubview:myScrollView];
  
  leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
  leftView.backgroundColor = [UIColor clearColor];
  [myScrollView addSubview:leftView];
  
  faceDetectorErrorView = [[KYFaceDetectorErrorView alloc] initWithFrame:CGRectMake(KScreenWidth, 0, KScreenWidth,KScreenHeight - 64)];
  faceDetectorErrorView.backgroundColor = [UIColor whiteColor];
  faceDetectorErrorView.delegate = self;
  //faceDetectorErrorView.hidden = YES;
  [myScrollView addSubview:faceDetectorErrorView];
  
  
  
  [self setupCamera];
  
  faceAnimationView = [[KYFaceAnimationView alloc] initWithFrame:CGRectMake(0, leftView.frame.size.height - 220 ,leftView.frame.size.width, 220)];
  [leftView addSubview:faceAnimationView];
  
  
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [faceDetector check];
  
  [faceAnimationView showAnimationLabel:FaceAnimationTypeDefault];
  
  [session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [session stopRunning];
  
}


-(void)dealloc {
  
  faceDetector = nil;
  
  
}


- (void)setupCamera {
  
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请设置中打开相机访问权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    return;
    
  }
  
  // create queue
  queueOutput = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
  queueMeta = dispatch_queue_create("MetaDataOutputQueue", DISPATCH_QUEUE_SERIAL);
  
  // create session
  session = [[AVCaptureSession alloc] init];
  [session setSessionPreset:AVCaptureSessionPreset640x480];
  
  // create device
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  AVCaptureDevice *device = nil;
  for (AVCaptureDevice *camera in devices) {
    if([camera position] == AVCaptureDevicePositionFront) {
      device = camera;
      break;
    }
  }
  AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
  
  // create video output
  AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
  [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES];
  [videoDataOutput setSampleBufferDelegate:faceDetector queue:queueOutput];
  
  // create meta output
  AVCaptureMetadataOutput *metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
  [metaDataOutput setMetadataObjectsDelegate:faceDetector queue:queueMeta];
  
  [session beginConfiguration];
  
  // add input & output to the session
  if ([session canAddInput:deviceInput]){
    [session addInput:deviceInput];
  }
  if ([session canAddOutput:videoDataOutput]){
    [session addOutput:videoDataOutput];
  }
  if ([session canAddOutput:metaDataOutput]){
    [session addOutput:metaDataOutput];
  }
  
  [session commitConfiguration];
  
  // set settings
  NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                     [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  [videoDataOutput setVideoSettings:rgbOutputSettings];
  [metaDataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeFace, nil]];
  
  // add layer
  previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
  [previewLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
  [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
  
  CALayer *rootLayer = [leftView layer];
  [rootLayer setMasksToBounds:YES];
  [previewLayer setFrame:[rootLayer bounds]];
  [rootLayer addSublayer:previewLayer];
  

}


-(UIBarButtonItem *)cancelButtonItem{
  if (!_cancelButtonItem) {
    UIButton* cancelButton = [[UIButton alloc] init];
    cancelButton.frame = CGRectMake(0, 0, 60, 44);
    [cancelButton adjustsImageWhenHighlighted];
    [cancelButton adjustsImageWhenDisabled];
    [cancelButton setTitle:@"取消认证" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
  }
  return _cancelButtonItem;
}


-(void)cancelButtonClicked:(id)sender {
  
  
  if (_delegate && [_delegate respondsToSelector:@selector(faceDetection:withCurrImage:withError:)]) {
    [_delegate faceDetection:KYFaceDetectionStatecancel withCurrImage:nil withError:nil];
  }
  
   [[self navigationController] popViewControllerAnimated:NO];
}


-(void)showFaceDetectorErrorView {
  

  leftView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight + 64);
  [previewLayer setFrame:[leftView bounds]];
  faceAnimationView.frame = CGRectMake(0, leftView.frame.size.height - 220 - 64 ,leftView.frame.size.width, 220);
  
  faceDetectorErrorView.hidden = NO;
  
  if (self.navigationController.navigationBarHidden == NO) {
    self.navigationController.navigationBarHidden = YES;
  }
  
  [UIView animateWithDuration:0.5 animations:^{
     myScrollView.contentOffset = CGPointMake(KScreenWidth, 0);
  } completion:^(BOOL finished) {
  
  }];
  
}

#pragma mark - KYFaceDetectorErrorViewDelegate
/**
 人脸验证失败界面点击重新认证
 */
-(void)faceDetectorErrorViewWithClickResetAuthButton {
  
  if (self.navigationController.navigationBarHidden == YES) {
    self.navigationController.navigationBarHidden = NO;
  }
 
  
  faceDetectorErrorView.hidden = YES;
  
  [UIView animateWithDuration:0.5 animations:^{
        myScrollView.contentOffset = CGPointMake(0, 0);
  } completion:^(BOOL finished) {
    
  }];
  
}

/**
 人脸验证失败界面点击取消认证
 */
-(void)faceDetectorErrorViewWithClickCancelButton {
  
  if (self.navigationController.navigationBarHidden == YES) {
    self.navigationController.navigationBarHidden = NO;
  }
 
  [self cancelButtonClicked:nil];
}



#pragma mark FaceDetector Delegate Methods

- (void)shouldValidate:(UIImage *)image {
  NSLog(@"Should Validate!");
  currImage = image;
  
}

- (void)motionDetected:(Motion)motion {
  
  if (motion == MotionReady){  //正视完成
    
    if (_delegate && [_delegate respondsToSelector:@selector(faceDetection:withCurrImage:withError:)]) {
      [_delegate faceDetection:KYFaceDetectionStateProcess withCurrImage:currImage withError:nil];
    }
    
     dispatch_async(dispatch_get_main_queue(), ^{
          [faceAnimationView showAnimationLabel:FaceAnimationTypeOpenMouth];
     });
    
  }else if (motion == MotionMouth){  //通过检测
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [faceAnimationView showAnimationLabel:FaceAnimationTypeFinish];
      
//      if (_delegate && [_delegate respondsToSelector:@selector(faceDetection:withCurrImage:withError:)]) {
//        [_delegate faceDetection:KYFaceDetectionStateSuccess withCurrImage:currImage withError:nil];
//      }
//
//      [[self navigationController] popViewControllerAnimated:NO];
//
    });

  }

  NSLog(@"motion::%u",motion);
  
//  if (motion == MotionMouth) {
//      [session stopRunning];
//  }
}

- (void)updateText {
  
  NSLog(@"statusText:%@",[faceDetector statusText]);
  
}

@end
