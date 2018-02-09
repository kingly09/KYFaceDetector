//
//  KYFaceDetectorErrorView.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KYFaceDetectorErrorViewDelegate <NSObject>

/**
 人脸验证失败界面点击重新认证
 */
-(void)faceDetectorErrorViewWithClickResetAuthButton;

/**
  人脸验证失败界面点击取消认证
 */
-(void)faceDetectorErrorViewWithClickCancelButton;

@end


@interface KYFaceDetectorErrorView : UIView

@property (nonatomic,weak) id<KYFaceDetectorErrorViewDelegate> delegate;

@end
