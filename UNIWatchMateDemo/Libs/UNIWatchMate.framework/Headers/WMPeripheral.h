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

/// 连接的目标设备 (The connected target device)
@property (nonatomic, strong) WMPeripheralTargetModel *target;
/// 设备连接 (Device connection)
@property (nonatomic, strong) WMConnectModel *connect;
/// 设备信息 (Device information)
@property (nonatomic, strong) WMDeviceInfoModel *infoModel;
/// 功能设置 (Function setting)
@property (nonatomic, strong) WMSettingsModel *settings;
/// 设备应用 (Equipment application)
@property (nonatomic, strong) WMAppsModel *apps;
/// 数据同步 (Data synchronization)
@property (nonatomic, strong) WMDatasSyncModel *datasSync;

@end

NS_ASSUME_NONNULL_END
