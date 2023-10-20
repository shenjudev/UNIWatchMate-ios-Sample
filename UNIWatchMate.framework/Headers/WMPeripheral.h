//
//  WMPeripheral.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDeviceInfoModel.h"
#import "WMSettingsModel.h"
#import "WMAppsModel.h"
#import "WMDatasSyncModel.h"
#import "WMConnectModel.h"
@class WMPeripheralTargetModel;

NS_ASSUME_NONNULL_BEGIN

@interface WMPeripheral : NSObject

/// 连接的目标设备
@property (nonatomic, strong) WMPeripheralTargetModel *target;
/// 设备连接
@property (nonatomic, strong) WMConnectModel *connect;
/// 设备信息
@property (nonatomic, strong) WMDeviceInfoModel *infoModel;
/// 功能设置
@property (nonatomic, strong) WMSettingsModel *settings;
/// 设备应用
@property (nonatomic, strong) WMAppsModel *apps;
/// 数据同步
@property (nonatomic, strong) WMDatasSyncModel *datasSync;

@end

NS_ASSUME_NONNULL_END
