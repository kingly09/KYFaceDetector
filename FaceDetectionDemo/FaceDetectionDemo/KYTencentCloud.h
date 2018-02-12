//
//  KYTencentCloud.h
//  BCEAccountAPP
//
//  Created by kingly on 2018/1/11.
//  Copyright © 2018年 Bamboocloud Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
//地域简称
extern NSString *const kFaceCosRegiontj;       // 北京一区（华北）
extern NSString *const kFaceCosRegionbj;       // 北京
extern NSString *const kFaceCosRegionsh;       // 上海（华东）
extern NSString *const kFaceCosRegiongz;       // 广州（华南）
extern NSString *const kFaceCosRegioncd;       // 成都（西南）
extern NSString *const kFaceCosRegionsgp;      // 新加坡
extern NSString *const kFaceCosRegionhk;       // 香港
extern NSString *const kFaceCosRegionca;       // 多伦多
extern NSString *const kFaceCosRegionger;      // 法兰克福

extern NSString *const kASEKey;           // 密钥

@protocol KYTencentCloudResponse <NSObject>
@end

@interface KYTencentCloudResponse : NSObject
@property (nonatomic,assign) int code;              //  服务器错误码，0 为成功
@property (nonatomic,copy) NSString  *message;      // 服务器返回的信息
@property (nonatomic,strong) NSDictionary   *data;  // 对应对象

@end

@interface KYTencentCloud : NSObject

@property (nonatomic,readwrite) NSString *appId;      // appid
@property (nonatomic,readwrite) NSString *secretId;   // secretId
@property (nonatomic,readwrite) NSString *secretKey;  // 密钥

@property (nonatomic,readwrite) NSString *region;     // 地区
@property (nonatomic,readwrite) NSString *bucket;     // bucket存储桶

@property (nonatomic,readwrite) NSString *multipleSign;   // 多次有效sign

/**
 * @brief 实例化对象
 */
+(instancetype)share;

/**
 初始化QCloud
 
 @param appId 腾讯云Appid
 @param secretId secretId
 @param secretKey 密钥
 */
-(void) setQCloudAppId:(NSString *)appId
          withSecretId:(NSString *)secretId
         withSecretKey:(NSString *)secretKey;

/**
 多次有效sign

 @param bucket bucket存储桶
 @param region 地区
 @param fileid 是否带文件
 @return 多次有效sign字符串
 */
-(NSString *)getMultipleSignWithBucket:(NSString *)bucket withRegion:(NSString *)region fileid:(NSString *)fileid;
/**
 过期时间的时间戳

 @param expired 当前时间过去多久
 */
- (NSString *) dateToExpiredString:(long )expired;

/**
 当前时间的时间戳
 @param date 时间
 */
- (NSString *) dateToTimestampString:(NSDate *)date;

/**
 检查请求返回的错误码

 @param response KYTencentCloudResponse
 @return YES 请求成功  NO 为请求失败
 */
- (BOOL )checkTencentCloudResponse:(KYTencentCloudResponse *)response;

@end
