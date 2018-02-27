//
//  KYFaceAnimationView.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,FaceAnimationType) {
  FaceAnimationTypeDefault    = 0,  //请正视屏幕
  FaceAnimationTypeOpenMouth,       //请张张嘴
  FaceAnimationTypeFinish           //检测完成
};

@interface KYFaceAnimationView : UIView


-(void)showAnimationLabel:(FaceAnimationType )faceAnimationType;


- (void)invalidateTimer;

@end
