//
//  WMWidgetModel.h
//  UNIWatchMate
//
//  Created by t_t on 2024/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMWidgetType) {
    WMWidgetTypeWidgetMusic = 1, // 音乐 （MUSICIANS）
    WMWidgetTypeWidgetActivityRecord = 2, // 活动记录（日常活动） （Activity record (daily activities)）
    WMWidgetTypeWidgetHeartRate = 3, // 心率 （Heart rate）
    WMWidgetTypeWidgetBloodOxygen = 4, // 血氧 （Blood oxygen）
    WMWidgetTypeWidgetBreathTrain = 5, // 呼吸训练 （Breathing training）
    WMWidgetTypeWidgetSport = 6, // 运动 （movement）
    WMWidgetTypeWidgetNotifyMsg = 7, // 消息 （message）
    WMWidgetTypeWidgetAlarm = 8, // 闹钟 （Alarm clock）
    WMWidgetTypeWidgetPhone = 9, // 电话 （telephone）
    WMWidgetTypeWidgetSleep = 10, // 睡眠 （Sleep）
    WMWidgetTypeWidgetWeather = 11, // 天气 （weather）
    WMWidgetTypeWidgetFindPhone = 12, // 寻找手机 （Find the phone）
    WMWidgetTypeWidgetCalculator = 13, // 计算器 （The Reckoner）
    WMWidgetTypeWidgetRemoteCamera = 14, // 遥控相机 （Remote control camera）
    WMWidgetTypeWidgetStopWatch = 15, // 秒表 （Second watch）
    WMWidgetTypeWidgetTimer = 16, // 计时器(倒计时) （Timer (countdown)）
    WMWidgetTypeWidgetFlashLight = 17, // 手电筒 （Flashlight）
    WMWidgetTypeWidgetSetting = 18, // 设置 （Settings）
};

@interface WMWidgetModel : NSObject

/// 数组元素为 WMWidgetType （The array element is WMWidgetType）
@property (nonatomic, strong) NSArray<NSNumber *> *widgets;

@end

NS_ASSUME_NONNULL_END
