//
//  FaceDetector.h
//  FDFramework
//
//  Created by Vincent on 30/1/2018.
//  Copyright © 2018 BambooCloud. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    MotionReady,
    MotionMouth,
    MotionHead,
    MotionEyes
} Motion;


@protocol FaceDetectorDelegate<NSObject>

@optional
- (void)shouldValidate:(UIImage *)image;
- (void)motionDetected:(Motion)motion;
- (void)updateText;
//- (void)test:(CMSampleBufferRef)buffer;
@end


@interface FaceDetector : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate> {
    
    NSString *statusText;
    
    __weak id<FaceDetectorDelegate> delegate;
    
}

@property (nonatomic, copy) NSString *statusText;
@property (weak) id<FaceDetectorDelegate> delegate;

- (void)startup;
- (void)check;

@end
