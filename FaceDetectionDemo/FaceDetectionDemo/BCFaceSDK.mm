//
//  BCFaceSDK.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/12.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "BCFaceSDK.h"
#import <FDFramework/FaceDetector.h>
#import "KYTencentCloud.h"

@interface BCFaceSDK () {
  
}
@property (nonatomic, strong) FaceDetector *faceDetector;

@end

@implementation BCFaceSDK

static BCFaceSDK *sharedFaceSDKObj = nil;
/**
 * @breif 获取实例
 */
+ (BCFaceSDK *) sharedInstance
{
  @synchronized (self)
  {
    if (sharedFaceSDKObj == nil){
      sharedFaceSDKObj = [[self alloc] init];
    }
  }
  return sharedFaceSDKObj;
}
/**
 * @breif 重写allocWithZone方法
 */
+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized (self) {
    if (sharedFaceSDKObj == nil) {
      sharedFaceSDKObj = [super allocWithZone:zone];
      return sharedFaceSDKObj;
    }
  }
  return nil;
}
/**
 * @breif 重写copyWithZone方法
 */
- (id) copyWithZone:(NSZone *)zone
{
  return self;
}
/**
 * @breif 重写init方法
 */
- (id)init
{
  @synchronized(self)
  {
    if (self = [super init])
    {
     
    }
    return self;
  }
}


-(void)initSDK {
  
  [self initSDKWithAppId:@"1255798840"
            withSecretId:@"AKID3vZzDClhAQRDk28wa2GF0XqukcHhDpX1"
           withSecretKey:@"MUN2UijV2KOEpBKEuLYXHm23qOhlcEbj"];
  
}

-(void)initSDKWithAppId:(NSString *)appId
           withSecretId:(NSString *)secretId
          withSecretKey:(NSString *)secretKey {
  
  if (appId.length == 0 || secretId.length == 0 || secretKey.length == 0) {
    NSLog(@"[BCFaceSDK] 初始化SDK失败");
    return;
  }
  
  // 初始化人脸SDK活体检查
  _faceDetector = [[FaceDetector alloc] init];
  [_faceDetector startup];
  
  //初始化腾讯云对象
  [[KYTencentCloud share] setQCloudAppId:appId withSecretId:secretId withSecretKey:secretKey];
  
}

-(id)getFaceDetector {
  
  return _faceDetector;
  
}



@end
