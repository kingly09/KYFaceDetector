//
//  KYFaceViewController.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceViewController.h"
#import "BCFaceSDK.h"

#import <AVFoundation/AVFoundation.h>
#import <FDFramework/FaceDetector.h>

#import "KYFaceAnimationView.h"
#import "KYFaceDetectorErrorView.h"

#import "KYFaceCompare.h"

#define KScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define KAuthTimeout 10.0     //认证超时时间
#define KNetworkAuthNum 3     //网络人脸对比的次数

#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define iPhoneX  [[UIScreen mainScreen] bounds].size.width >= 375.0f && [[UIScreen  mainScreen] bounds].size.height >= 812.0f && isiPhone
#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0

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
  
  NSTimer *authTimeOutTimer;        //认证时间
  NSTimer *networkAuthTimeOutTimer; //网路人脸对比认证
  
  BOOL isSdkSucc;            //是否sdk检查人脸成功
  BOOL isNetworkCheckSucc;   //是否网络人脸比对成功
  
  BOOL isTimeOut;            //是否认证时间超时
  
  NSData *comparedPictureData; //需要比对的图片
}

// 取消认证
@property (nonatomic) UIBarButtonItem *cancelButtonItem;



@end

@implementation KYFaceViewController

+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
  UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
  
  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
  
  UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return scaledImage;   //返回的就是已经改变的图片
}

+ (NSData *)compressImageWithImage:(UIImage *)image
                          aimWidth:(CGFloat)width
                         aimLength:(NSInteger)length
                  accuracyOfLength:(NSInteger)accuracy {
  
  UIImage * newImage = [self OriginImage:image scaleToSize:CGSizeMake(width, width * image.size.height / image.size.width)];
  
  NSData  * data = UIImageJPEGRepresentation(newImage, 1);
  NSInteger imageDataLen = [data length];
  
  if (imageDataLen <= length + accuracy) {
    return data;
  }else{
    NSData * imageData = UIImageJPEGRepresentation( newImage, 0.99);
    if (imageData.length < length + accuracy) {
      return imageData;
    }
    
    CGFloat maxQuality = 1.0;
    CGFloat minQuality = 0.0;
    int flag = 0;
    
    while (1) {
      CGFloat midQuality = (maxQuality + minQuality)/2;
      
      if (flag == 6) {
        return UIImageJPEGRepresentation(newImage, minQuality);
      }
      flag ++;
      
      NSData * imageData = UIImageJPEGRepresentation(newImage, midQuality);
      NSInteger len = imageData.length;
      
      if (len > length+accuracy) {
       
        maxQuality = midQuality;
        continue;
      }else if (len < length-accuracy){
        minQuality = midQuality;
        continue;
      }else{
        return imageData;
        break;
      }
    }
  }
}



- (void)viewDidLoad {
  [super viewDidLoad];
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
     NSData *imageData = [KYFaceViewController compressImageWithImage:_comparedPicture aimWidth:KScreenWidth * 2 aimLength:3*1024*1024 accuracyOfLength:1024];
     UIImage *image = [UIImage imageWithData: imageData];
     imageData = UIImageJPEGRepresentation(image, 0.1);
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
      comparedPictureData = imageData;
    });
  });

  self.view.backgroundColor = [UIColor whiteColor];
  self.title = @"人脸识别";
  [self.navigationItem setHidesBackButton:YES];
  [self.navigationItem setRightBarButtonItems:@[self.cancelButtonItem]];
  
  // get the face detector reference
  faceDetector = (FaceDetector *)[BCFaceSDK sharedInstance].getFaceDetector;
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
  if (iPhoneX) {
    faceAnimationView.frame = CGRectMake(0, leftView.frame.size.height - 220 - 44 ,leftView.frame.size.width, 220);
  }
  [leftView addSubview:faceAnimationView];
  
  
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self restSession];
  
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [session stopRunning];
  
}


-(void)dealloc {
  
  currImage = nil;
  
  _comparedPicture = nil;
  
  faceDetector = nil;
  
  [myScrollView removeFromSuperview];
  myScrollView = nil;
  
  [self invalidateAuthTimeOutTimer];
  [self invalidateNetworkAuthTimeOutTimer];
}

/**
 注销认证超时的定时器
 */
-(void)invalidateAuthTimeOutTimer {
  
  if ([authTimeOutTimer isValid]) {
    [authTimeOutTimer invalidate];
    authTimeOutTimer = nil;
  }
  
}

/**
 注销网路人脸对比认证的定时器
 */
-(void)invalidateNetworkAuthTimeOutTimer {
  
  if ([networkAuthTimeOutTimer isValid]) {
    [networkAuthTimeOutTimer invalidate];
    networkAuthTimeOutTimer = nil;
  }
  
}

/**
 重新开始检查人脸
 */
-(void)restSession {
  
  isTimeOut = NO;
  
  isSdkSucc = NO;
  
  isNetworkCheckSucc = NO;
  
  [faceDetector check];
  
  [faceAnimationView showAnimationLabel:FaceAnimationTypeDefault];
  
  [session startRunning];
  
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
  
  AVCaptureConnection *videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
  [videoConnection setVideoMirrored:YES];
  [videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
  
  // add layer
  previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
  [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
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
  
  isTimeOut = NO;
  
  isSdkSucc = NO;
  
  isNetworkCheckSucc = NO;
  
  [self invalidateAuthTimeOutTimer];
  [self invalidateNetworkAuthTimeOutTimer];
  
  [session stopRunning];
  
  leftView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight + 64);
  [previewLayer setFrame:[leftView bounds]];
  faceAnimationView.frame = CGRectMake(0, leftView.frame.size.height - 220 - 64 ,leftView.frame.size.width, 220);
  
  if (iPhoneX) {
    faceAnimationView.frame = CGRectMake(0, leftView.frame.size.height - 220 - 108 ,leftView.frame.size.width, 220);
  }
  
  [faceAnimationView showAnimationLabel:FaceAnimationTypeDefault];
  
  faceDetectorErrorView.hidden = NO;
  
  if (self.navigationController.navigationBarHidden == NO) {
    self.navigationController.navigationBarHidden = YES;
  }
  
  myScrollView.contentOffset = CGPointMake(KScreenWidth, 0);
 
  
}


/**
 人脸认证的时间超时
 */
-(void)authTimeOutTimerMethod {
  
  if (isSdkSucc == NO || isNetworkCheckSucc == NO) {
  
    isTimeOut = YES;
    
    [self showFaceDetectorErrorView];
    
  }
  
}



/**
 网络请求检查人脸对比
 */
- (void)reqNetworkAuthTimeOutTimer {
  
  NSLog(@"[BCFaceSDK]  开始网络请求");
  
  if ([networkAuthTimeOutTimer isValid]) {
    [networkAuthTimeOutTimer invalidate];
    networkAuthTimeOutTimer = nil;
  }
  
  NSMethodSignature *method = [KYFaceViewController instanceMethodSignatureForSelector:@selector(invocationTimeRun:)];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:method];
  
  networkAuthTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 invocation:invocation repeats:YES];
  
  // 设置方法调用者
  invocation.target = self;
  // 这里的SEL需要和NSMethodSignature中的一致
  invocation.selector = @selector(invocationTimeRun:);
  // 设置参数
  // //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd)
  // 如果有多个参数, 可依次设置3 4 5 ...
  [invocation setArgument:&networkAuthTimeOutTimer atIndex:2];
  [invocation invoke];
  
  NSLog(@"[BCFaceSDK]  start");
}

- (void)invocationTimeRun:(NSTimer *)timer {
  
  static NSInteger num = 0;

  num++;
  
  NSData *currImageData  = UIImagePNGRepresentation(currImage);
  if (currImageData.length ==  0) {
    NSLog(@"[BCFaceSDK] 比对图片异常 currImageData");
    return;
  }
  if (comparedPictureData.length ==  0) {
    NSLog(@"[BCFaceSDK] 比对图片异常 comparedPictureData");
    if (num == 0) {
      [self showFaceDetectorErrorView];
    }
    return;
  }
  
  //如果是网络检查成功了，取消网络人脸对比的校正
  if (isNetworkCheckSucc == YES) {
    if ([timer isValid]) {
      [timer invalidate];
      timer = nil;
    }
    NSLog(@"[BCFaceSDK]  网络检查成功过");
    return;
  }
 
  if (num > KNetworkAuthNum) {
    
    if ([timer isValid]) {
      [timer invalidate];
      timer = nil;
    }
    num = 0;
    
    NSLog(@"[BCFaceSDK] 已经超过3次了");
    return;
  }
  
  if (isNetworkCheckSucc == NO && isTimeOut == NO) {
    
     NSLog(@"[BCFaceSDK] 第%ld次人脸比对 %@", (long)num, timer);
    
    [[KYFaceCompare share] faceCompareWithImageA:comparedPictureData withImageB:currImageData succ:^(KYFaceCompareRsp *rsp) {
     
      if (isNetworkCheckSucc == NO) {
        
        if (rsp.similarity >= 75.0) {
          
          NSLog(@"[BCFaceSDK] 比对成功");
          isNetworkCheckSucc = YES;
          
          if ([timer isValid]) {
            [timer invalidate];
          }

          [self faceDetectionSucc];
          
        }else {
          NSLog(@"[BCFaceSDK] 比对失败");
          isNetworkCheckSucc = NO;
          
          if (num == 0) {
            [self showFaceDetectorErrorView];
          }
          
        }
      }else{
         NSLog(@"[BCFaceSDK] 已经比对成功过");
      }
      
    } fail:^(KYFaceResponse *faceResponse) {
      NSLog(@"[BCFaceSDK] 比对异常");
      isNetworkCheckSucc = NO;
      if (num == 0) {
        
        [self showFaceDetectorErrorView];
        
      }
      
    }];
  }

}


/**
 人脸比对成功
 */
-(void)faceDetectionSucc {
  
  if (isSdkSucc == YES && isNetworkCheckSucc == YES && isTimeOut == NO) {
    
    dispatch_async(dispatch_get_main_queue(), ^{

      [faceAnimationView showAnimationLabel:FaceAnimationTypeFinish];
      
      if (_delegate && [_delegate respondsToSelector:@selector(faceDetection:withCurrImage:withError:)]) {
        [_delegate faceDetection:KYFaceDetectionStateSuccess withCurrImage:currImage withError:nil];
      }

      [[self navigationController] popViewControllerAnimated:NO];
      
      [session stopRunning];
      
    });
  }
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
  
  [self restSession];
  
  myScrollView.contentOffset = CGPointMake(0, 0);
  
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
  NSLog(@"[BCFaceSDK] Should Validate!");
  currImage = image;
}

- (void)motionDetected:(Motion)motion {
  
  NSLog(@"[BCFaceSDK] motion::%u",motion);
  
  if (motion == MotionReady){  //正视完成
    
    NSLog(@"[BCFaceSDK] 正视完成");
    
    if (_delegate && [_delegate respondsToSelector:@selector(faceDetection:withCurrImage:withError:)]) {
      [_delegate faceDetection:KYFaceDetectionStateProcess withCurrImage:currImage withError:nil];
    }
    
     dispatch_async(dispatch_get_main_queue(), ^{
       
       [faceAnimationView showAnimationLabel:FaceAnimationTypeOpenMouth];
       
      [self reqNetworkAuthTimeOutTimer];   //进行网络人脸对比
      [self invalidateAuthTimeOutTimer];   //进行超时监听
     
       authTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:KAuthTimeout target:self selector:@selector(authTimeOutTimerMethod) userInfo:nil repeats:NO];
       
     });
    
  }else if (motion == MotionMouth){  //通过检测
    
    isSdkSucc = YES;
    NSLog(@"[BCFaceSDK] 已通过检测");
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      [faceAnimationView showAnimationLabel:FaceAnimationTypeFinish];
      
    });
    
    [self faceDetectionSucc];

  }
  
}

- (void)updateText {
  
  //NSLog(@"statusText:%@",[faceDetector statusText]);
  
}

@end
