//
//  BtUtils.h
//  JuPlus
//
//  Created by 孙强 on 2022/1/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BtUtils : NSObject
+(NSString *)encryptString:(NSString *)string key:(NSString *)key;
+(bool)verificationCmd:(NSString *)cmd oldData:(NSString *)oldData old2Data:(NSString *)old2Data keyOri:(NSString *)keyOri;
+(NSString *)crc:(NSData*)data;
+(NSString *)crc8maxim:(NSData*)data;
+(NSData *)watchCrc16:(NSData*)data result:(uint16_t)result;
+(uint16_t)watchCrc16Uint:(NSData*)data result:(uint16_t)result;
@end

NS_ASSUME_NONNULL_END
