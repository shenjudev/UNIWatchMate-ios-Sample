//
//  WMFileAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMProgressModel.h"
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, WMFileType) {
    // 升级文件
    WMActivityTypeOTA,
    // 表盘文件
    WMActivityTypeDIAL,
    // 音乐文件
    WMActivityTypeMUSIC,
    // 电子书文件
    WMActivityTypeTXT
};
@interface WMFileAppModel : NSObject<WMSupportProtocol>

/// 传输单个文件
/// - Parameters:
///   - file: 文件本地地址
///   - type: 文件类型
- (RACSignal<WMProgressModel *> *)startTransferFile:(NSURL *)file fileType:(WMFileType)type;

/// 传输多个文件
/// - Parameters:
///   - file: 文件本地地址
///   - type: 文件类型
- (RACSignal<WMProgressModel *> *)startTransferMultipleFile:(NSArray<NSURL*> *)file fileType:(WMFileType)type;

/// 是否支持多文件传输
- (BOOL)isSupportMultiple;

/// 取消文件传输
- (void)cancelTransfer;

@end

NS_ASSUME_NONNULL_END
