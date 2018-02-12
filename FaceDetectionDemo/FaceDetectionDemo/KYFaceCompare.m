//
//  KYFaceCompare.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/9.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceCompare.h"
#import <AFNetworking/AFNetworking.h>
#define KOcrFaceCompare  @"http://service.image.myqcloud.com/face/compare"   //OCR - 人脸对比
#import "NSString+KYCustomMethod.h"

@implementation KYFaceResponse

@end

@implementation KYFaceCompareRsp

@end




@implementation KYFaceCompare

/**
 * @brief 实例化对象
 */
+ (instancetype)share
{
  return [[KYFaceCompare alloc]init];
}


- (void)faceCompareWithImageA:(NSData *)imageA
                   withImageB:(NSData *)imageB
                         succ:(KYFaceCompareRspSucc )success
                         fail:(KYFaceResponseHander  )failure {
  
  KYFaceResponse *imageOCRFail = [[KYFaceResponse alloc] init];
  imageOCRFail.code = -40000;
  imageOCRFail.message = @"人脸比对失败";
  
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  NSString *basicAuthorization = [NSString stringWithFormat:@"Basic %@",[KYFaceCompare share].multipleSign];
  [manager.requestSerializer setValue:basicAuthorization forHTTPHeaderField:@"Authorization"];
  [manager POST:KOcrFaceCompare parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    [formData appendPartWithFormData:[self.appId dataUsingEncoding:NSUTF8StringEncoding]
                                name:@"appid"];
    
    if (imageA.length > 0) {
      
      [formData appendPartWithFileData:imageA
                                  name:@"imageA"
                              fileName:[NSString stringWithFormat:@"imageA_%ld.jpg",[NSString nowTimeSeconds]] mimeType:@"image/jpeg"];
    }
    if (imageB.length > 0) {
      
      [formData appendPartWithFileData:imageB
                                  name:@"imageB"
                              fileName:[NSString stringWithFormat:@"imageB_%ld.jpg",[NSString nowTimeSeconds]] mimeType:@"image/jpeg"];
      
    }
    
  } progress:^(NSProgress * _Nonnull uploadProgress) {
    
    //NSLog(@"uploadProgress:%lld",uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
    NSDictionary *responseDic = responseObject;
    KYFaceResponse *faceResponse  = [[KYFaceResponse alloc] init];
    faceResponse.code = [[responseDic objectForKey:@"code"] intValue];
    faceResponse.data = [responseDic objectForKey:@"data"];
    if (faceResponse.code == 0 && faceResponse.data) {
      KYFaceCompareRsp *faceCompareRsp = [[KYFaceCompareRsp alloc] init];
      faceCompareRsp.session_id  = [faceResponse.data objectForKey:@""];
      faceCompareRsp.similarity  = [[faceResponse.data objectForKey:@"similarity"]intValue];
      faceCompareRsp.fail_flag   = [[faceResponse.data objectForKey:@"fail_flag"]intValue];
      
      success(faceCompareRsp);
      
    }else{
      failure(imageOCRFail);
    }
    
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    failure(imageOCRFail);
  }];
  
}


@end
