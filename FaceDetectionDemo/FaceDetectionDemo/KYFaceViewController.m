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


@interface KYFaceViewController ()<FaceDetectorDelegate> {
  
  
  AVCaptureSession *session;
  AVCaptureVideoPreviewLayer *previewLayer;
  dispatch_queue_t queueOutput;
  dispatch_queue_t queueMeta;
  
  FaceDetector *faceDetector;
  
  KYFaceAnimationView *faceAnimationView;
}

// 取消认证
@property (nonatomic) UIBarButtonItem *cancelButtonItem;

@end

@implementation KYFaceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"人脸识别";
  [self.navigationItem setRightBarButtonItems:@[self.cancelButtonItem]];
  
  // get the face detector reference
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  faceDetector = [delegate faceDetector];
  [faceDetector setDelegate:self];
  
  [self setupCamera];
  
  faceAnimationView = [[KYFaceAnimationView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220,self.view.frame.size.width , 220)];
  [[self view] addSubview:faceAnimationView];
  
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
  
  
  CALayer *rootLayer = [[self view] layer];
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
  
   [[self navigationController] popViewControllerAnimated:NO];
}


#pragma mark FaceDetector Delegate Methods

- (void)shouldValidate:(UIImage *)image {
  NSLog(@"Should Validate!");
}

- (void)motionDetected:(Motion)motion {
  
  if (motion == MotionReady){  //正视完成
    
     dispatch_async(dispatch_get_main_queue(), ^{
          [faceAnimationView showAnimationLabel:FaceAnimationTypeOpenMouth];
     });
  }else if (motion == MotionMouth){  //通过检测
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [faceAnimationView showAnimationLabel:FaceAnimationTypeFinish];
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
