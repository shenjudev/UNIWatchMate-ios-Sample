//
//  WMDeviceInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WMFeature) {
    WMFeatureWeatherSync = 0,        // 天气同步开关
    WMFeatureFitnessRecord,          // 健身记录
    WMFeatureHeartRate,              // 心率
    WMFeatureCameraRemoteV1,         // 相机遥控器（V1）
    WMFeatureNotificationManagement, // 通知管理
    WMFeatureAlarmSetting,           // 闹钟设置
    WMFeatureLocalMusicSync,         // 本地音乐同步
    WMFeatureContactSync,            // 联系人同步
    WMFeatureFindWatch,              // 查找手表
    WMFeatureFindPhone,              // 查找手机
    WMFeatureAppViewSetting,         // 【设置】应用视图
    WMFeatureIncomingCallRing,       // 【设置】来电响铃
    WMFeatureNotificationFeedback,   // 【设置】通知触感
    WMFeatureCrownFeedback,          // 【设置】表冠触感反馈
    WMFeatureSystemFeedback,         // 【设置】系统触感反馈
    WMFeatureWristWakeScreen,        // 【设置】抬腕亮屏
    WMFeatureBloodOxygen,            // 血氧
    WMFeatureBloodPressure,          // 血压
    WMFeatureBloodSugar,             // 血糖
    WMFeatureSleepTracking,          // 睡眠（设置+数据）
    WMFeatureEbookSync,              // 电子书同步
    WMFeatureSlowMode,               // 是否是慢速模式（w20a）
    WMFeatureCameraRemotePreview,    // 相机遥控器支持预览
    WMFeatureVideoFileSync,          // 视频文件同步（avi）
    WMFeaturePaymentCode,            // 收款码
    WMFeatureWatchFaceMarket,        // 表盘市场
    WMFeatureNotificationExpansion,  // 通知列表是否全部展开
    WMFeatureCallBluetooth,          // 通话蓝牙
    WMFeatureShowCallBluetoothOff,   // 显示关闭通话蓝牙
    WMFeatureEmergencyContacts,      // 紧急联系人
    WMFeatureSyncFavContacts,        // 同步收藏联系人
    WMFeatureQuickReply,             // 快捷回复
    WMFeatureStepGoal,               // 步数目标
    WMFeatureCalorieGoal,            // 卡路里目标
    WMFeatureExerciseDurationGoal,   // 活动时长目标
    WMFeatureSedentaryReminder,      // 久坐提醒
    WMFeatureDrinkWaterReminder,     // 喝水提醒
    WMFeatureHandWashingReminder,    // 洗手提醒
    WMFeatureAutoHeartRateMonitoring,// 心率自动检测
    WMFeatureREMSleepTracking,       // REM快速眼动
    WMFeatureMultipleSportModes,     // 是否支持多种运动
    WMFeatureFixedSportTypes,        // 显示固定运动类型
    WMFeatureAutoSportRecognitionStart, // 运动自识别开始
    WMFeatureAutoSportRecognitionEnd,   // 运动自识别结束
    WMFeatureAlarmLabel,             // 闹钟标签
    WMFeatureAlarmNote,              // 闹钟备注
    WMFeatureWorldClock,             // 世界时钟
    WMFeatureAppSwitchDeviceLanguage,// app切换设备语言
    WMFeatureWidgets,                // 小部件
    WMFeatureAppAdjustsDeviceVolume, // App调整设备音量
    WMFeatureQuietHeartRateAlert,    // 安静心率过高提醒
    WMFeatureExerciseHeartRateAlert, // 运动心率过高提醒
    WMFeatureDailyHeartRateAlert,    // 日常心率过高提醒
    WMFeatureContinuousBloodOxygen,  // 连续血氧
    WMFeatureBluetoothDisconnectionAlert, // 蓝牙断连提醒设置
    WMFeatureCallBluetoothBLENameMatching, // 通话蓝牙与BLE是否同名
    WMFeatureEventReminder,          // 事件提醒
    WMFeatureScreenOnReminder,       // 亮屏提醒
    WMFeatureRestartDevice,          // 重启设备
    
    WMFeatureNavigation = 64,        // 导航
    WMFeatureCompass = 65            // 指南针
};


// 特性列表
@interface WMFeatureSet : NSObject
- (instancetype)initWithData:(NSData *)data;
// 是否支持该功能
- (BOOL)isFeatureEnabled:(WMFeature)feature;
@end


// 手表特性
@interface WMFeatureSetModel : NSObject
// 特性清单版本
@property (nonatomic, assign) NSInteger feature_version;
// 特性清单开关
@property (strong, nonatomic) WMFeatureSet *feature_mask;
// 支持的最大联系人个数
@property (nonatomic, assign) NSInteger max_contacts;
// 侧按钮个数
@property (nonatomic, assign) NSInteger side_button_count;
// 固定运动个数
@property (nonatomic, assign) NSInteger fixed_sport_count;
// 可变运动个数
@property (nonatomic, assign) NSInteger variable_sport_count;
@end


@interface WMDeviceBaseInfo : NSObject
/// 设备型号
@property (nonatomic, copy) NSString * _Nullable model;
/// 设备MAC地址
@property (nonatomic, copy) NSString * _Nullable macAddress;
/// 设备版本
@property (nonatomic, copy) NSString * _Nullable version;
/// 设备ID
@property (nonatomic, copy) NSString * _Nullable deviceId;
/// 蓝牙名称
@property (nonatomic, copy) NSString * _Nullable bluetoothName;
/// 设备名称
@property (nonatomic, copy) NSString * _Nullable deviceName;
/// 其他参数
@property (nonatomic, strong) NSDictionary * _Nullable otherInfo;
@end


@interface WMDeviceBatteryModel : NSObject
/// 设备电量百分比0~100
@property (nonatomic, assign) NSInteger battery;
/// 设备是否充电
@property (nonatomic, assign) BOOL isCharging;
@end


/// 设备信息
@interface WMDeviceInfoModel : NSObject
/// 设备电量
@property (nonatomic, strong) RACSignal<WMDeviceBatteryModel *> *battery;
@property (nonatomic, assign, readonly) WMDeviceBatteryModel *batteryValue;
@property (nonatomic, strong, nullable) WMFeatureSetModel *featureSetModel;

/// 主动获取设备信息
- (RACSignal<WMDeviceBaseInfo *> *)wm_getBaseinfo;
/// 主动获取电量
- (RACSignal<WMDeviceBatteryModel *> *)wm_getBattery;
/// 主动获取特性
- (RACSignal<WMFeatureSetModel *> *)wm_getFeatureSet;
@end

NS_ASSUME_NONNULL_END
