//
//  BCTencentCloud.m
//  BCEAccountAPP
//
//  Created by kingly on 2018/1/11.
//  Copyright © 2018年 Bamboocloud Co., Ltd. All rights reserved.
//

#import "BCTencentCloud.h"
#import "GTMBase64.h"
#import "NSString+KYCustomMethod.h"

#define KTencentCloudASEKeyKey  @"2916054684417924"

NSString *const kCosRegiontj  =  @"tj";   // 北京一区（华北）

NSString *const kCosRegionbj  = @"bj";    // 北京
NSString *const kCosRegionsh  = @"sh";    // 上海（华东）
NSString *const kCosRegiongz  = @"gz";    // 广州（华南）
NSString *const kCosRegioncd  = @"cd";    // 成都（西南）
NSString *const kCosRegionsgp = @"sgp";   // 新加坡
NSString *const kCosRegionhk  = @"hk";    // 香港
NSString *const kCosRegionca  = @"ca";    // 多伦多
NSString *const kCosRegionger = @"ger";   //法兰克福

NSString *const kASEKey  = KTencentCloudASEKeyKey;  // 固定的key


@implementation BCTencentCloudResponse
@end

@interface BCTencentCloud () {
    
    NSString *srcStrOnce;
    NSData *srcStrOnceData;
    NSString *hacStr;
}


@end


@implementation BCTencentCloud

/**
 * @brief 实例化对象
 */
+ (instancetype)share
{
    return [[BCTencentCloud alloc]init];
}

- (instancetype)init
{
    if (self = [super init]) {
        _appId     = @"1255798840";
        _secretId  = @"AKID3vZzDClhAQRDk28wa2GF0XqukcHhDpX1";
        _secretKey = @"MUN2UijV2KOEpBKEuLYXHm23qOhlcEbj";
        
        _bucket     = @"epassidcard";    //管理身份证所有图片
        _region     = kCosRegiongz;      //广州（华南
        
        [self setQCloudAppId:_appId withSecretId:_secretId withSecretKey:_secretKey];
    }
    return self;
}

-(void) setQCloudAppId:(NSString *)appId
          withSecretId:(NSString *)secretId
         withSecretKey:(NSString *)secretKey {
    
    
    self.appId = appId;
    self.secretId = secretId;
    self.secretKey = secretKey;
    
    self.multipleSign = [self getMultipleSignWithBucket:self.bucket withRegion:self.region fileid:nil];
}


-(NSString *)getMultipleSignWithBucket:(NSString *)bucket withRegion:(NSString *)region fileid:(NSString *)fileid {
    
    
    self.bucket     = bucket;
    self.region     = region;
    
    NSString *appid = self.appId;
    NSString *sbucket = self.bucket;
    NSString *sSecret_id = self.secretId;
    NSString *sSecret_key = self.secretKey;
    NSString *onceExpired = [self dateToExpiredString:2592000];
    NSString *current = [self dateToTimestampString:[NSDate date]];
    NSString *rdm = [NSString stringWithFormat:@"%d",[NSString getRandomNumber:10000 to:1000000000]];
    NSString *userid = @"0";
    NSString *fileidStr = [NSString isBlankString:fileid]?@"":fileid;
    
    //多次有效
    srcStrOnce = [NSString stringWithFormat:@"a=%@&b=%@&k=%@&e=%@&t=%@&r=%@&u=%@&f=%@",appid,sbucket,sSecret_id,onceExpired,current,rdm,userid,fileidStr];
    
    srcStrOnceData = [srcStrOnce dataUsingEncoding:NSUTF8StringEncoding];
    NSData  *hacStrData = [NSString HmacSha1:sSecret_key data:srcStrOnce];
    NSMutableData *mData = [[NSMutableData alloc] init];
    [mData appendData:hacStrData];
    [mData appendData:srcStrOnceData];
    
    self.multipleSign =  [GTMBase64 stringByEncodingData:mData];
    
    return self.multipleSign;
}

- (NSString *) dateToExpiredString:(long )expired {
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970] + expired)];
    return timeSp;
}

- (NSString *) dateToTimestampString:(NSDate *)date {
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}


- (BOOL )checkTencentCloudResponse:(BCTencentCloudResponse *)response {
  
  if (response.code == 0) {
    return YES;
  }
  
  return NO;
  
}


@end
