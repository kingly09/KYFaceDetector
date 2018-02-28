//
//  KYFaceDetectorErrorView.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "KYFaceDetectorErrorView.h"
//RGB转UIColor(16进制)
#define RGB16(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface KYFaceDetectorErrorView (){
  
  UIView      *noteView;
  UIImageView *errorImageView;
  UILabel     *errorLabel;
  UILabel     *faceNoteLabel;
  UIButton    *resetAuthButton;
  UIButton    *cancelButton;
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
  
  NSLog(@"[BCFaceSDK] KYFaceDetectorErrorView dealloc");
  
  
}

//自定义
- (void)setupCustomView
{
  
  noteView = [[UIView alloc] init];
  [self addSubview:noteView];
  
  
  errorImageView = [[UIImageView alloc] init];
  errorImageView.frame = CGRectMake((self.frame.size.width - 64)/2, 0, 64, 64);
  errorImageView.image = [UIImage imageNamed:@"ic_home_face_fail"];
  [noteView addSubview:errorImageView];
  
  
  errorLabel = [[UILabel alloc] init];
  errorLabel.frame = CGRectMake(0, errorImageView.frame.size.height + 20, self.frame.size.width, 24);
  errorLabel.font = [UIFont systemFontOfSize:24];
  errorLabel.textColor = RGB16(0x323232);
  errorLabel.textAlignment = NSTextAlignmentCenter;
  errorLabel.text = @"人脸验证失败";
  [noteView addSubview:errorLabel];
  
  
  
  faceNoteLabel = [[UILabel alloc] init];
  faceNoteLabel.frame = CGRectMake(0, errorLabel.frame.size.height + errorLabel.frame.origin.y + 20, self.frame.size.width, 24);
  faceNoteLabel.font = [UIFont systemFontOfSize:14];
  faceNoteLabel.textColor = RGB16(0x323232);
  faceNoteLabel.textAlignment = NSTextAlignmentCenter;
  faceNoteLabel.text = @"验证时请保证光线充足、人脸清晰、动作到位";
  [noteView addSubview:faceNoteLabel];
  
  resetAuthButton = [UIButton buttonWithType:UIButtonTypeCustom];
  resetAuthButton.frame = CGRectMake(30,faceNoteLabel.frame.size.height + faceNoteLabel.frame.origin.y + 20, self.frame.size.width - 60, 44);
  [resetAuthButton setTitle:@"重新认证" forState:UIControlStateNormal];
  resetAuthButton.backgroundColor = RGB16(0x3495fc);
  resetAuthButton.titleLabel.font = [UIFont systemFontOfSize:16];
  resetAuthButton.layer.cornerRadius = 5;
  resetAuthButton.clipsToBounds = YES;
  [resetAuthButton setTitleColor:RGB16(0xffffff) forState:UIControlStateNormal];
  resetAuthButton.clipsToBounds = YES;
  [resetAuthButton setImage:[UIImage imageNamed:@"ic_id_positive"] forState:UIControlStateNormal];
  [resetAuthButton addTarget:self action:@selector(clickResetAuthButton:) forControlEvents:UIControlEventTouchUpInside];
  [noteView addSubview:resetAuthButton];
  
  
  cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
  cancelButton.frame = CGRectMake(30,resetAuthButton.frame.size.height + resetAuthButton.frame.origin.y + 20, self.frame.size.width - 60, 44);
  [cancelButton setTitle:@"取消认证" forState:UIControlStateNormal];
  cancelButton.backgroundColor = RGB16(0x989898);
  cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
  cancelButton.layer.cornerRadius = 5;
  cancelButton.clipsToBounds = YES;
  [cancelButton setTitleColor:RGB16(0xffffff) forState:UIControlStateNormal];
  cancelButton.clipsToBounds = YES;
  [cancelButton setImage:[UIImage imageNamed:@"ic_id_positive"] forState:UIControlStateNormal];
  [cancelButton addTarget:self action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
  [noteView addSubview:cancelButton];
  
  
  noteView.frame = CGRectMake(0, (self.frame.size.height - (cancelButton.frame.size.height + cancelButton.frame.origin.y))/2, self.frame.size.width, cancelButton.frame.size.height + cancelButton.frame.origin.y);
  
}


-(void)clickResetAuthButton:(id)sender {
  if (_delegate && [_delegate respondsToSelector:@selector(faceDetectorErrorViewWithClickResetAuthButton)]) {
    [_delegate faceDetectorErrorViewWithClickResetAuthButton];
  }
  
}

-(void)clickCancelButton:(id)sender {
  
  if (_delegate && [_delegate respondsToSelector:@selector(faceDetectorErrorViewWithClickCancelButton)]) {
    [_delegate faceDetectorErrorViewWithClickCancelButton];
  }
}

@end
