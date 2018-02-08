//
//  KYFaceViewController.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KYFaceDetectionState) {
  KYFaceDetectionStateNone    = 0,  //无任何操作
  KYFaceDetectionStateProcess ,     //正在检查
  KYFaceDetectionStateSuccess,      //检查成功
  KYFaceDetectionStatecancel,      //取消认证
  KYFaceDetectionStateFailure       //认证失败
};


@protocol KYFaceViewControllerDelegate <NSObject>

/**
 人脸比对结果

 @param faceDetectionState 人脸比对的状态
 @param currImage  当前获取的人脸头像
 @param detectionError 人脸比对错误信息
 */
- (void)faceDetection:(KYFaceDetectionState )faceDetectionState
        withCurrImage:(UIImage *)currImage
            withError:(NSError *)detectionError;

@end


@interface KYFaceViewController : UIViewController

@property (nonatomic,weak) id<KYFaceViewControllerDelegate> delegate;

@property (nonatomic,strong) UIImage *comparedPicture;  // 需要比较的图片


@end
