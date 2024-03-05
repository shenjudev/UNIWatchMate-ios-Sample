//
//  WMWidgetModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMWidgetType) {
    WMWidgetTypeWidgetMusic = 1, // 音乐
    WMWidgetTypeWidgetActivityRecord = 2, // 活动记录（日常活动）
    WMWidgetTypeWidgetHeartRate = 3, // 心率
    WMWidgetTypeWidgetBloodOxygen = 4, // 血氧
    WMWidgetTypeWidgetBreathTrain = 5, // 呼吸训练
    WMWidgetTypeWidgetSport = 6, // 运动
    WMWidgetTypeWidgetNotifyMsg = 7, // 消息
    WMWidgetTypeWidgetAlarm = 8, // 闹钟
    WMWidgetTypeWidgetPhone = 9, // 电话
    WMWidgetTypeWidgetSleep = 10, // 睡眠
    WMWidgetTypeWidgetWeather = 11, // 天气
    WMWidgetTypeWidgetFindPhone = 12, // 寻找手机
    WMWidgetTypeWidgetCalculator = 13, // 计算器
    WMWidgetTypeWidgetRemoteCamera = 14, // 遥控相机
    WMWidgetTypeWidgetStopWatch = 15, // 秒表
    WMWidgetTypeWidgetTimer = 16, // 计时器(倒计时)
    WMWidgetTypeWidgetFlashLight = 17, // 手电筒
    WMWidgetTypeWidgetSetting = 18, // 设置
};

@interface WMWidgetModel : NSObject

/// 数组元素为 WMWidgetType
@property (nonatomic, strong) NSArray<NSNumber *> *widgets;

@end

NS_ASSUME_NONNULL_END
