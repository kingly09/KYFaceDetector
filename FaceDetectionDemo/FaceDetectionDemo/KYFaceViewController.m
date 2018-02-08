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


@interface KYFaceViewController ()<FaceDetectorDelegate> {
  
  
  AVCaptureSession *session;
  AVCaptureVideoPreviewLayer *previewLayer;
  dispatch_queue_t queueOutput;
  dispatch_queue_t queueMeta;
  
  UILabel *labelStatus;
  
  FaceDetector *faceDetector;
}

- (void)setupCamera;
- (void)cancel:(id)sender;


@end

@implementation KYFaceViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.title = @"人脸识别";
  
  // get the face detector reference
  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  faceDetector = [delegate faceDetector];
  [faceDetector setDelegate:self];
  
  [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [faceDetector check];
  
  [session startRunning];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [session stopRunning];
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
  [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
  [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  CALayer *rootLayer = [[self view] layer];
  [rootLayer setMasksToBounds:YES];
  [previewLayer setFrame:[rootLayer bounds]];
  [rootLayer addSublayer:previewLayer];
  
  labelStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, [[self view] frame].size.width, 30)];
  [labelStatus setTextColor:[UIColor greenColor]];
  [labelStatus setFont:[UIFont boldSystemFontOfSize:32]];
  [labelStatus setTextAlignment:NSTextAlignmentCenter];
  [[self view] addSubview:labelStatus];
  
  UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
  [btnCancel setFrame:CGRectMake(20, [[self view] frame].size.height - 50, [[self view] frame].size.width - 40, 30)];
  [[btnCancel titleLabel] setFont:[UIFont boldSystemFontOfSize:26]];
  [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
  [btnCancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
  [[self view] addSubview:btnCancel];
  
  //layer = [[AVSampleBufferDisplayLayer alloc] init];
  //[layer setFrame:[self view].frame];
  //[[[self view] layer] addSublayer:layer];
  
}

- (void)cancel:(id)sender {
  [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark FaceDetector Delegate Methods

- (void)shouldValidate:(UIImage *)image {
  NSLog(@"Should Validate!");
}

- (void)motionDetected:(Motion)motion {
  if (motion == MotionMouth) {
    [session stopRunning];
  }
}

- (void)updateText {
  dispatch_async(dispatch_get_main_queue(), ^{
    [labelStatus setText:[faceDetector statusText]];
  });
}

@end
