//
//  KYFaceAnimationView.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceAnimationView.h"

@interface KYFaceAnimationView ()
{
  
  UILabel *animationLabel; //动作说明
  UIImageView *animationImageView; //动画图片
  
}
@end

@implementation KYFaceAnimationView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    [self setupCustomView];
  }
  return self;
}

//自定义
- (void)setupCustomView
{
   //动作说明
  animationLabel = [[UILabel alloc] init];
  animationLabel.font = [UIFont systemFontOfSize:20];
  animationLabel.textColor = [UIColor whiteColor];
  animationLabel.backgroundColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:0.5];
  animationLabel.textAlignment = NSTextAlignmentCenter;
  [self addSubview:animationLabel];
  
  //动画图片
  animationImageView = [[UIImageView alloc] init];
  animationImageView.contentMode =  UIViewContentModeCenter;
  animationImageView.contentMode =  UIViewContentModeScaleAspectFill;
  [self addSubview:animationImageView];
  
}

-(void)showAnimationLabel:(FaceAnimationType )faceAnimationType {
  
  NSString *animationStr = @"";
  if (faceAnimationType == FaceAnimationTypeDefault ) {
      animationStr = @"请正视屏幕";
  }else if (faceAnimationType == FaceAnimationTypeOpenMouth ) {
      animationStr = @"请张张嘴";
  }else if (faceAnimationType == FaceAnimationTypeFinish ) {
    animationStr = @"您已通过检查";
  }
  NSLog(@"animationStr::%@",animationStr);
  
   CGRect titleLabelRect = [animationStr boundingRectWithSize:CGSizeMake(self.frame.size.width - 40,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil];
  animationLabel.text = animationStr;
  animationLabel.frame = CGRectMake( (self.frame.size.width - (titleLabelRect.size.width + 20))/2, 0, titleLabelRect.size.width + 20, 40);
  
  
  animationImageView.frame = CGRectMake((self.frame.size.width - 150)/2, 55, 150, 150);
  
  if (faceAnimationType == FaceAnimationTypeDefault ) {
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
  }else if (faceAnimationType == FaceAnimationTypeOpenMouth ) {
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_mouth"];
  }else{
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
  }

}


@end
