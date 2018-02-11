//
//  NSString+KYCustomMethod.h
//  FaceDetectionDemo
//
//  Created by kingly on 2018/2/9.
//  Copyright © 2018年 Bambooclound Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KYCustomMethod)


/**
 * @brief 判断字符串为空和只为空格解决办法
 */
+ (BOOL)isBlankString:(NSString *)string;
/**
 获取一个随机整数，范围在[from,to]，包括from，包括to
 */
+(int )getRandomNumber:(int)from to:(int)to;
/**
 当前时间总秒数
 */
+(long )nowTimeSeconds;

/**
 HmacSHA1加密
 @param key 加密Key
 @param data 需要加密
 */
+ (NSData *)HmacSha1:(NSString *)key data:(NSString *)data;

@end
