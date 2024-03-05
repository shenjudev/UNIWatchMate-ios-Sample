//
//  WMError.h
//  UNIWatchMate
//
//  Created by t_t on 2024/1/20.
//

#import <Foundation/Foundation.h>

#ifndef WMError_h
#define WMError_h

// 更新后的枚举，用作错误代码
typedef NS_ENUM(NSInteger, WMErrorCode) {
    WMErrorCodeDisconnect,            // 设备未连接
    WMErrorCodeBusy,                  // 设备繁忙
    WMErrorCodeSport,                 // 运动中
    WMErrorCodeLowBattery,            // 设备电量低
    WMErrorCodeLowStorage,            // 内存不足
    WMErrorCodeReady,                 // 准备好
    WMErrorCodeDialHasItsLimit,       // 表盘数量已达上限
    WMErrorCodeCustomDialFail,        // 自定义表盘失败
    WMErrorCodeFileError,             // 文件有误
    WMErrorCodeOther                  // 其他状态
};

NSError * WMErrorMake(WMErrorCode code, NSString *description);

#endif /* WMError_h */
