//
//  WMReminderModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 时间范围
@interface WMTimeRange : NSObject

/// 开始（精确到小时分钟，年月日秒忽略）
@property (nonatomic, strong) NSDate * start;
/// 结束（精确到小时分钟，年月日秒忽略）
@property (nonatomic, strong) NSDate * end;

@end

/// 时间频次
typedef NS_ENUM(NSInteger, WMTimeFrequency) {
    /// 每30分钟一次
    WMTimeFrequencyEvery30Minutes,
    /// 每1小时一次
    WMTimeFrequencyEvery1Hour,
    /// 每1小时30分钟一次
    WMTimeFrequencyEvery1Hour30Minutes
};

/// 免打扰
@interface WMNoDisturb : NSObject

/// 是否启用
@property (nonatomic, assign) BOOL isEnabled;

/// 时间范围
@property (nonatomic, strong) WMTimeRange *timeRange;

@end

/// Sedentary reminder(久坐/喝水提醒)
@interface WMReminderModel : NSObject

/// Whether to enable(是否启用)
@property (nonatomic, assign) BOOL isEnabled;

/// Time range(时间范围)
@property (nonatomic, strong) WMTimeRange *timeRange;

/// Frequency(频率)
@property (nonatomic, assign) WMTimeFrequency frequency;

/// No-disturb lunch break(午休免打扰)
@property (nonatomic, strong) WMNoDisturb *noDisturbLunchBreak;

@end

NS_ASSUME_NONNULL_END
