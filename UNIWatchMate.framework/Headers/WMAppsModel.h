//
//  WMAppsModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMDialAppModel.h"
#import "WMFileAppModel.h"
#import "WMAlarmAppModel.h"
#import "WMContactsAppModel.h"
#import "WMWeatherForecastAppModel.h"
#import "WMConfigMotionAppModel.h"
#import "WMConfigHeartRateAppModel.h"
#import "WMFindAppModel.h"
#import "WMCameraAppModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 设备应用
@interface WMAppsModel : NSObject

/// 表盘
@property (nonatomic, strong) WMDialAppModel *dialApp;
/// 文件传输
@property (nonatomic, strong) WMFileAppModel *fileApp;
/// 闹钟
@property (nonatomic, strong) WMAlarmAppModel *alarmApp;
/// 通讯录
@property (nonatomic, strong) WMContactsAppModel *contactsApp;
/// 天气预报
@property (nonatomic, strong) WMWeatherForecastAppModel *weatherForecastApp;
/// 运动项目配置
@property (nonatomic, strong) WMConfigMotionAppModel *configMotionApp;
/// 心率
@property (nonatomic, strong) WMConfigHeartRateAppModel *configHeartRateApp;
/// 查找
@property (nonatomic, strong) WMFindAppModel *findApp;
/// 相机
@property (nonatomic, strong) WMCameraAppModel *cameraApp;

@end

NS_ASSUME_NONNULL_END
