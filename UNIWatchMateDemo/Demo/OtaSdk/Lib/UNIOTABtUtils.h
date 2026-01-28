//
//  UNIOTABtUtils.h
//  UNIWatchMateDemo - OTA SDK
//
//  重命名自 BtUtils (原作者：孙强)
//  专用于 OTA SDK，避免与 SJWatchLib 冲突
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// OTA SDK 专用的蓝牙工具类
/// 提供CRC16校验等功能
@interface UNIOTABtUtils : NSObject

/// 加密字符串
+(NSString *)encryptString:(NSString *)string key:(NSString *)key;

/// 验证命令
+(bool)verificationCmd:(NSString *)cmd oldData:(NSString *)oldData old2Data:(NSString *)old2Data keyOri:(NSString *)keyOri;

/// 计算CRC校验值（返回字符串）
+(NSString *)crc:(NSData*)data;

/// 计算CRC校验值（返回长整型）
+(long long)crcLong:(NSData*)data;

/// 计算CRC8 Maxim校验值
+(NSString *)crc8maxim:(NSData*)data;

/// 计算CRC16校验值（返回NSData）
+(NSData *)watchCrc16:(NSData*)data result:(uint16_t)result;

/// 计算CRC16校验值（返回UInt16）
+(uint16_t)watchCrc16Uint:(NSData*)data result:(uint16_t)result;

/**
 * 计算大数据量的 CRC16 并返回 NSData
 * 专门用于 OTA 文件校验，支持大文件分块处理
 *
 * @param data 要计算 CRC16 的大数据
 * @param result CRC16 计算的初始值（通常为0xFFFF）
 * @return CRC16 结果 NSData（4字节），如果输入数据为空或内存分配失败则返回 nil
 */
+ (nullable NSData *)watchCrc16BigData:(NSData *)data result:(uint16_t)result;

@end

NS_ASSUME_NONNULL_END
