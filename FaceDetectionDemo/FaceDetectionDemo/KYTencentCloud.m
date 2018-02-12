//
//  KYTencentCloud.m
//  BCEAccountAPP
//
//  Created by kingly on 2018/1/11.
//  Copyright © 2018年 Bamboocloud Co., Ltd. All rights reserved.
//

#import "KYTencentCloud.h"
#import "GTMBase64.h"
#import "NSString+KYCustomMethod.h"

#define KTencentCloudASEKeyKey  @"2916054684417924"

NSString *const kFaceCosRegiontj  =  @"tj";   // 北京一区（华北）

NSString *const kFaceCosRegionbj  = @"bj";    // 北京
NSString *const kFaceCosRegionsh  = @"sh";    // 上海（华东）
NSString *const kFaceCosRegiongz  = @"gz";    // 广州（华南）
NSString *const kFaceCosRegioncd  = @"cd";    // 成都（西南）
NSString *const kFaceCosRegionsgp = @"sgp";   // 新加坡
NSString *const kFaceCosRegionhk  = @"hk";    // 香港
NSString *const kFaceCosRegionca  = @"ca";    // 多伦多
NSString *const kFaceCosRegionger = @"ger";   //法兰克福

NSString *const kASEKey  = KTencentCloudASEKeyKey;  // 固定的key


@implementation KYTencentCloudResponse
@end

@interface KYTencentCloud () {
    
    NSString *srcStrOnce;
    NSData *srcStrOnceData;
    NSString *hacStr;
}


@end


@implementation KYTencentCloud

/**
 * @brief 实例化对象
 */
+ (instancetype)share
{
    return [[KYTencentCloud alloc]init];
}

- (instancetype)init
{
    if (self = [super init]) {
        _appId     = @"1255798840";
        _secretId  = @"AKID3vZzDClhAQRDk28wa2GF0XqukcHhDpX1";
        _secretKey = @"MUN2UijV2KOEpBKEuLYXHm23qOhlcEbj";
        
        _bucket     = @"epassidcard";    //管理身份证所有图片
        _region     = kFaceCosRegiongz;      //广州（华南
        
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


- (BOOL )checkTencentCloudResponse:(KYTencentCloudResponse *)response {
  
  if (response.code == 0) {
    return YES;
  }
  
  return NO;
  
}


@end
