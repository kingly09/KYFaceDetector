//
//  BCFaceSDK.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/12.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "BCFaceSDK.h"
#import <FDFramework/FaceDetector.h>

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



@end
