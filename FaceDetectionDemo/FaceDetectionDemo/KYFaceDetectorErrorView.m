//
//  KYFaceDetectorErrorView.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceDetectorErrorView.h"

@interface KYFaceDetectorErrorView (){
  
  
}

@end

@implementation KYFaceDetectorErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self setupCustomView];
  }
  return self;
}

-(void)dealloc {
  
  NSLog(@"KYFaceDetectorErrorView dealloc");
  
  
}

//自定义
- (void)setupCustomView
{
  
  
}

@end
