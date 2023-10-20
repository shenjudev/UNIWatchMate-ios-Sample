//
//  WMSportDataType.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#ifndef WMSportDataType_h
#define WMSportDataType_h

// 运动数据类型
typedef NS_ENUM(NSInteger, WMSportDataType) {
    WMSportDataTypeStartTimestamp,         // 运动开始时间（时间戳）
    WMSportDataTypeEndTimestamp,           // 运动结束时间（时间戳）
    WMSportDataTypeTotalDuration,          // 运动总时长（秒）
    WMSportDataTypeTotalMileage,           // 总里程（米）
    WMSportDataTypeCalories,               // 活动卡路里（卡）
    WMSportDataTypeFastestPace,            // 最快配速（秒/公里）
    WMSportDataTypeSlowestPace,            // 最慢配速（秒/公里）
    WMSportDataTypeFastestSpeed,           // 最快速度（秒/公里）
    WMSportDataTypeTotalSteps,             // 总步数（步）
    WMSportDataTypeMaxStepFrequency,       // 最大步频（步/秒）
    WMSportDataTypeAverageHeartRate,       // 平均心率（次/分）
    WMSportDataTypeMaxHeartRate,           // 最大心率（次/分）
    WMSportDataTypeMinHeartRate,           // 最小心率（次/分）
    WMSportDataTypeLimitHeartRateDuration, // 心率-极限时长（秒）
    WMSportDataTypeAnaerobicEnduranceDuration, // 心率-无氧耐力时长（秒）
    WMSportDataTypeAerobicEnduranceDuration,   // 心率-有氧耐力时长（秒）
    WMSportDataTypeFatBurningDuration,         // 心率-燃脂时长（秒）
    WMSportDataTypeWarmUpDuration              // 心率-热身时长（秒）
};

#endif /* WMSportDataType_h */
