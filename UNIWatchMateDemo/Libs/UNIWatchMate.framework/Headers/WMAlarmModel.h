//
//  WMAlarmModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(uint8_t, WMAlarmRepeat) {
    WMAlarmRepeatNone      = 0,
    WMAlarmRepeatMonday    = 1 << 0,
    WMAlarmRepeatTuesday   = 1 << 1,
    WMAlarmRepeatWednesday = 1 << 2,
    WMAlarmRepeatThursday  = 1 << 3,
    WMAlarmRepeatFriday    = 1 << 4,
    WMAlarmRepeatSaturday  = 1 << 5,
    WMAlarmRepeatSunday    = 1 << 6,
};

/// 闹钟
@interface WMAlarmModel : NSObject

/// 闹钟ID
@property (nonatomic, assign) NSInteger identifier;
/// 闹钟名称
@property (nonatomic, strong) NSString *alarmName;
/// 闹钟时间小时
@property (nonatomic, assign) NSInteger alarmHour;
/// 闹钟时间分钟
@property (nonatomic, assign) NSInteger alarmMinute;
/// 闹钟重复设置
@property (nonatomic, assign) WMAlarmRepeat repeatOptions;
/// 闹钟是否开启
@property (nonatomic, assign) BOOL isOn;

@end

NS_ASSUME_NONNULL_END
