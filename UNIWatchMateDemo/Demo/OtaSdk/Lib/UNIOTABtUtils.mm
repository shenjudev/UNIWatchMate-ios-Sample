//
//  UNIOTABtUtils.mm
//  UNIWatchMateDemo - OTA SDK
//
//  重命名自 BtUtils.m (原作者：孙强)
//  专用于 OTA SDK，避免与 SJWatchLib 冲突
//

#import "UNIOTABtUtils.h"
#import "UNIOTACLFSR.h"
#import <UIKit/UIKit.h>

@implementation UNIOTABtUtils

// MARK: - 加密相关方法

+(NSString *)encryptString:(NSString *)string key:(NSString *)key{
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt64 keyUint16 = strtoul([key UTF8String], 0, 16);
    uint8_t *dataUint8 = (uint8_t *)[UNIOTABtUtils hexStringToByteArray:string];
    UInt32 lengthUint32 = (UInt32)[string length] / 2;
    clfsr.Encrypt_Data(keyUint16,dataUint8,lengthUint32);
    NSData *result = [NSData dataWithBytes:dataUint8 length:lengthUint32];
    free(dataUint8);
    return [[UNIOTABtUtils dataToHexStr:result] uppercaseString];
}

+(bool)verificationCmd:(NSString *)cmd oldData:(NSString *)oldData old2Data:(NSString *)old2Data keyOri:(NSString *)keyOri{
    bool right = false;
    NSString *key2 = [UNIOTABtUtils getTheAccumulatedValueAnd:keyOri];
    NSString *substring = [cmd  substringWithRange: NSMakeRange(32, 96)];
    NSString *encode = [UNIOTABtUtils encryptString:substring key:key2];
    NSString *substring1 = [encode substringWithRange: NSMakeRange(0, 32)];
    NSString *substring2 = [encode substringWithRange: NSMakeRange(32, 32)];
    Byte * bytes1 = (Byte *)[UNIOTABtUtils hexStringToByteArray:substring1];
    Byte * bytes2 = (Byte *)[UNIOTABtUtils hexStringToByteArray:substring2];
    Byte * bytes3 = (Byte *)[UNIOTABtUtils hexStringToByteArray:oldData];
    int bytes1Length = (int)[substring1 length]/ 2;
    int bytes2Length = (int)[substring2 length]/ 2;
    Byte *  bytes4 = (Byte *)malloc(bytes1Length + bytes2Length);
        for (int j = 0; j < bytes1Length; j++) {
            bytes4[j] = (Byte) (bytes1[j] ^ bytes3[j]);
        }
        for (int j = 0; j < bytes2Length; j++) {
            bytes4[j + bytes2Length] = (Byte) (bytes2[j] ^ bytes3[j]);
        }
    NSData *result = [NSData dataWithBytes:bytes4 length:bytes1Length + bytes2Length];
    NSString *resultStr = [UNIOTABtUtils dataToHexStr:result];
    right = [resultStr isEqualToString:old2Data];
    
    free(bytes1);
    free(bytes2);
    free(bytes3);
    free(bytes4);
    
    return  right;
}

// MARK: - CRC校验方法

+(NSString *)crc8maxim:(NSData*)data{
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    uint8_t bytes[lengthUint32];
    [data getBytes:&bytes length:lengthUint32];
    long long crc = clfsr.crc8_maxim(bytes, lengthUint32);
    return [[NSString stringWithFormat:@"%02llX",crc] uppercaseString];
}

+(NSString *)crc:(NSData*)data{
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    uint16_t result = 0xFFFF;
    uint8_t bytes[lengthUint32];
    [data getBytes:&bytes length:lengthUint32];
    long long crc = clfsr.get_crc(result, bytes, lengthUint32);
    return [[NSString stringWithFormat:@"%08llX",crc] uppercaseString];
}

+(long long)crcLong:(NSData*)data{
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    uint16_t result = 0xFFFF;
    uint8_t bytes[lengthUint32];
    [data getBytes:&bytes length:lengthUint32];
    long long crc = clfsr.get_crc(result, bytes, lengthUint32);
    return crc;
}

+(NSData *)watchCrc16:(NSData*)data result:(uint16_t)result {
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    uint8_t bytes[lengthUint32];
    [data getBytes:&bytes length:lengthUint32];
    long long crc = clfsr.get_crc(result, bytes, lengthUint32);
    return [NSData dataWithBytes:&crc length:4];
}

+(uint16_t)watchCrc16Uint:(NSData*)data result:(uint16_t)result {
    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    uint8_t bytes[lengthUint32];
    [data getBytes:&bytes length:lengthUint32];
    return clfsr.get_crc(result, bytes, lengthUint32);
}

/**
 * 计算大数据量的 CRC16（OTA 文件专用）
 * 使用分块处理避免栈溢出
 */
+(NSData *)watchCrc16BigData:(NSData*)data result:(uint16_t)result {
    if (!data || [data length] == 0) {
        return nil;
    }

    UNIOTACore::UNIOTACLFSR clfsr = UNIOTACore::UNIOTACLFSR();
    UInt32 lengthUint32 = (UInt32)[data length];
    
    // 动态分配内存以处理大数据量，避免栈内存溢出
    uint8_t *bytes = (uint8_t *)malloc(lengthUint32);
    if (!bytes) {
        // 内存分配失败
        return nil;
    }
    
    [data getBytes:bytes length:lengthUint32];
    
    // 分块处理数据以优化性能和内存使用
    const UInt32 chunkSize =  1024 * 1024; // 1MB 每块
    UInt32 processed = 0;
    uint16_t currentResult = result;
    
    while (processed < lengthUint32) {
        UInt32 bytesToProcess = MIN(chunkSize, lengthUint32 - processed);
        currentResult = clfsr.get_crc(currentResult, bytes + processed, bytesToProcess);
        processed += bytesToProcess;
    }
    
    // 释放动态分配的内存
    free(bytes);
    
    // 将 CRC16 结果转换为 NSData 对象（4字节）
    uint32_t finalResult = (uint32_t)currentResult;
    NSData *crcData = [NSData dataWithBytes:&finalResult length:4];
    return crcData;
}

// MARK: - 辅助工具方法

+(Byte *)hexStringToByteArray:(NSString *)string{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte *bytes = (Byte *)malloc([hexString length] / 2);
    int j=0;
    for(int i=0;i<[hexString length];i++) {
        int int_ch;
        unichar hex_char1 = [hexString characterAtIndex:i];
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16;
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i];
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48);
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55;
        else
            return nil;
        
        int_ch = int_ch1+int_ch2;
        bytes[j] = int_ch;
        j++;
    }
    return bytes;
}

+(NSString *)getTheAccumulatedValueAnd:(NSString *)oldData{
    UInt16 total = 0;
    int len = (int)[oldData length];
    int num = 0;
    while (num < len) {
        NSString *s = [oldData substringWithRange:NSMakeRange( num,2)];
        total += (int)strtoul([s UTF8String],0,16);;
        num = num + 2;
    }
    NSString *hex = [NSString stringWithFormat:@"%04X",total];
    return [hex uppercaseString];
}

+(NSData *)stringToData:(NSString *)string{
    NSData *data = [string  dataUsingEncoding:NSUTF8StringEncoding];
    return  data;
}

+ (uint8_t)uint8FromBytes:(NSData *)data
{
    uint8_t val = 0;
    [data getBytes:&val length:1];
    return val;
}

+ (NSString *)dataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return [string uppercaseString];
}

@end
