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
  UIImageView *animationDefaultImageView; //默认图片
  UIImageView *animationImageView; //动画图片
  
  NSTimer *animationTimer;  //张嘴动画
  BOOL  isOpenMouth;   //是否是张嘴
  
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

-(void)dealloc {
  
  NSLog(@"[BCFaceSDK] KYFaceAnimationView dealloc");
  [self invalidateTimer];
  
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
  
  
  animationDefaultImageView = [[UIImageView alloc] init];
  animationDefaultImageView.contentMode =  UIViewContentModeCenter;
  animationDefaultImageView.contentMode =  UIViewContentModeScaleAspectFill;
  [self addSubview:animationDefaultImageView];
  
  
  //动画图片
  animationImageView = [[UIImageView alloc] init];
  animationImageView.contentMode =  UIViewContentModeCenter;
  animationImageView.contentMode =  UIViewContentModeScaleAspectFill;
  [self addSubview:animationImageView];
  
}

-(void)showAnimationLabel:(FaceAnimationType )faceAnimationType {
  
  isOpenMouth = NO;
  
  NSString *animationStr = @"";
  if (faceAnimationType == FaceAnimationTypeDefault ) {
      animationStr = @"请正视前置摄像头";
  }else if (faceAnimationType == FaceAnimationTypeOpenMouth ) {
      animationStr = @"请张嘴";
  }else if (faceAnimationType == FaceAnimationTypeFinish ) {
    animationStr = @"对比验证中...";
  }
 
   CGRect titleLabelRect = [animationStr boundingRectWithSize:CGSizeMake(self.frame.size.width - 40,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil];
  animationLabel.text = animationStr;
  animationLabel.frame = CGRectMake( (self.frame.size.width - (titleLabelRect.size.width + 20))/2, 0, titleLabelRect.size.width + 20, 40);

  
  animationDefaultImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
  animationDefaultImageView.frame = CGRectMake((self.frame.size.width - 150)/2, 55, 150, 150);
  animationDefaultImageView.hidden = NO;
  
  if (faceAnimationType == FaceAnimationTypeDefault ) {
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
    animationImageView.frame = CGRectMake(-150, 55, 150, 150);
    animationImageView.hidden = YES;
    
    [self invalidateTimer];
    
  }else if (faceAnimationType == FaceAnimationTypeOpenMouth ) {
    animationDefaultImageView.hidden = YES;
    animationImageView.hidden = NO;
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_mouth"];
    isOpenMouth = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
      animationImageView.frame = CGRectMake((self.frame.size.width - 150)/2, 55, 150, 150);
    } completion:^(BOOL finished) {
      
      [self showOpenMouthAnimation];
      
    }];
    
    
  }else{
    animationImageView.hidden = YES;
    animationImageView.frame = CGRectMake(-150, 55, 150, 150);
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
    
    [self invalidateTimer];
  }

}


/**
 显示张嘴动画
 */
-(void)showOpenMouthAnimation {
  

  animationTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(runLoopOpenMouthAnimation) userInfo:nil repeats:YES];
  [animationTimer fire];
  [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
  
  
}

-(void)runLoopOpenMouthAnimation {
  
  if ( isOpenMouth == YES) {
     NSLog(@"[BCFaceSDK] close mouth");
     isOpenMouth = NO;
     animationImageView.image  = [UIImage imageNamed:@"ic_home_face_default"];
  }else{
     NSLog(@"[BCFaceSDK] open mouth");
    isOpenMouth = YES;
    animationImageView.image  = [UIImage imageNamed:@"ic_home_face_mouth"];
  }
  
}

/**
 注销定时器
 */
- (void)invalidateTimer {
  
  if ([animationTimer isValid]) {
    [animationTimer invalidate];
    animationTimer = nil;
  }
   isOpenMouth = NO;
  
}
@end
