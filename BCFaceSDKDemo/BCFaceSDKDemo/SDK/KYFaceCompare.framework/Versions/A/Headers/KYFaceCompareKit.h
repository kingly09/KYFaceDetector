//
//  KYFaceCompareKit.h
//  Pods
//
//  Created by kingly on 2018/2/27.
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

extern NSString *const kY_ASEKey;              // 密钥


@protocol KYTencentCloudResponse <NSObject>
@end

@interface KYTencentCloudResponse : NSObject
@property (nonatomic,assign) int code;              //  服务器错误码，0 为成功
@property (nonatomic,copy) NSString  *message;      // 服务器返回的信息
@property (nonatomic,strong) NSDictionary   *data;  // 对应对象

@end


@protocol KYFaceResponse <KYTencentCloudResponse>
@end

@interface KYFaceResponse : KYTencentCloudResponse

@property (nonatomic,copy) NSString  *url;         // 当前图片的 url

@end

/**
 Face 的相似性以及五官相似度的结果
 */
@protocol KYFaceCompareRsp <NSObject>

@end

@interface KYFaceCompareRsp : NSObject

@property (nonatomic,copy) NSString *session_id;    // 相应请求的 session 标识符
@property int similarity;      // 两个 face 的相似度
@property (nonatomic,assign) int fail_flag;       // 标志失败图片，1 为第一张，2 为第二张（失败时返回）


@end

typedef void(^KYFaceResponseHander )(KYFaceResponse *faceResponse);   //人脸回包
typedef void(^KYFaceCompareRspSucc )(KYFaceCompareRsp *rsp);          //人脸比对成功回调


@interface KYFaceCompareKit : NSObject

@property (nonatomic,readonly) NSString *appId;      // appid
@property (nonatomic,readonly) NSString *secretId;   // secretId
@property (nonatomic,readonly) NSString *secretKey;  // 密钥

@property (nonatomic,readonly) NSString *region;     // 地区
@property (nonatomic,readonly) NSString *bucket;     // bucket存储桶

@property (nonatomic,readonly) NSString *multipleSign;   // 多次有效sign


/**
 * @brief 实例化对象
 */
+ (instancetype)share;

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
 计算两个 Face 的相似性以及五官相似度。
 
 @param imageA A 图片的 资源
 @param imageB B 图片的 资源
 @param success 成功回调
 @param failure 失败回调
 */
- (void)faceCompareWithImageA:(NSData *)imageA
                   withImageB:(NSData *)imageB
                         succ:(KYFaceCompareRspSucc )success
                         fail:(KYFaceResponseHander  )failure;

@end
