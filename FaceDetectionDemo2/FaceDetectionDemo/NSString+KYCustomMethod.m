//
//  NSString+KYCustomMethod.m
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/9.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import "NSString+KYCustomMethod.h"
#include <CommonCrypto/CommonHMAC.h>

@implementation NSString (KYCustomMethod)

/**
 * @brief 判断字符串为空和只为空格解决办法
 */
+ (BOOL)isBlankString:(NSString *)string
{
  if (string == nil) {
    
    return YES;
    
  }
  
  if (string == NULL) {
    
    return YES;
    
  }
  
  if ([string isKindOfClass:[NSNull class]]) {
    
    return YES;
    
  }
  
  if ([string isEqual:[NSNull null]]) {
    
    return YES;
    
  }
  
  if (string.length > 0) {
    if ([[string lowercaseString] isEqualToString:@"<null>"]) {
      return YES;
    }
    
    if ([[string lowercaseString] isEqualToString:@"(null)"]) {
      return YES;
    }
  }
  //去除两端的空格
  if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
    
    return YES;
    
  }
  
  return NO;
}

/**
 获取一个随机整数，范围在[from,to]，包括from，包括to
 */
+ (int )getRandomNumber:(int)from to:(int)to
{
  float randomNumber = arc4random() % ( to - from + 1) + from;
  return (int)randomNumber;
}

/**
 当前时间总秒数
 */
+(long )nowTimeSeconds {
  
  NSDate *nowDate=[NSDate date];
  long nowTime = [nowDate timeIntervalSince1970];//当前时间总秒数
  return nowTime;
}

//HmacSHA1加密
+ (NSData *)HmacSha1:(NSString *)key data:(NSString *)data {
  const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
  const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
  //Sha256:
  // unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  //sha1
  unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
  CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  
  NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                        length:sizeof(cHMAC)];
  return HMAC;
}


@end
