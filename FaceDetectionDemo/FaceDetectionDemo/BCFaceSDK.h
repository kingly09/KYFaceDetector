//
//  BCFaceSDK.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/12.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BCFaceSDK : NSObject

/**
 * @breif 获取实例
 */
+ (BCFaceSDK *) sharedInstance;
/**
 初始化SDK
 */
-(void)initSDK;

/**
 初始化SDK

 @param appId 对应的appId
 @param secretId 对应的secretId
 @param secretKey 对应项目的密钥
 */
-(void)initSDKWithAppId:(NSString *)appId
           withSecretId:(NSString *)secretId
          withSecretKey:(NSString *)secretKey;

/**
 获得人脸识别对象
 */
-(id)getFaceDetector;

@end
