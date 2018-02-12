//
//  KYFaceCompare.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/9.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYTencentCloud.h"

@protocol KYFaceResponse <KYTencentCloudResponse>
@end

@interface KYFaceResponse : KYTencentCloudResponse

@property (nonatomic,copy) NSString  *url;         // 当前图片的 url

@end

/**
 Face 的相似性以及五官相似度的结果
 */
@protocol KYFaceCompareRsp <NSObject>

@end
@interface KYFaceCompareRsp : NSObject

@property (nonatomic,copy) NSString *session_id;    // 相应请求的 session 标识符
@property int similarity;      // 两个 face 的相似度
@property (nonatomic,assign) int fail_flag;       // 标志失败图片，1 为第一张，2 为第二张（失败时返回）


@end

typedef void(^KYFaceResponseHander )(KYFaceResponse *faceResponse);   //人脸回包
typedef void(^KYFaceCompareRspSucc )(KYFaceCompareRsp *rsp);          //人脸比对成功回调


@interface KYFaceCompare : KYTencentCloud


/**
 * @brief 实例化对象
 */
+(instancetype)share;

/**
 计算两个 Face 的相似性以及五官相似度。
 
 @param imageA A 图片的 资源
 @param imageB B 图片的 资源
 @param success 成功回调
 @param failure 失败回调
 */
- (void)faceCompareWithImageA:(NSData *)imageA
                   withImageB:(NSData *)imageB
                         succ:(KYFaceCompareRspSucc )success
                         fail:(KYFaceResponseHander  )failure;
@end
