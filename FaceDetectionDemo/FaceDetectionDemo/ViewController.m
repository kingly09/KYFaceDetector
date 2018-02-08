//
//  ViewController.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/8.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "KYFaceViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)onClickSelfPortraits:(id)sender {
  
  
}

- (IBAction)onClickFaceDetect:(id)sender {
  
  KYFaceViewController *faceController = [[KYFaceViewController alloc] init];
   [[self navigationController] pushViewController:faceController animated:YES];
  
}

@end
