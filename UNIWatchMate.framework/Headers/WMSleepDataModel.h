//
//  WMSleepDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 睡眠状态
typedef NS_ENUM(NSInteger, WMSleepStatusType) {
    //清醒
    WMSleepStatusAwake = 0,
    //浅睡
    WMSleepStatusLight = 1,
    //深睡
    WMSleepStatusDeep = 2,
    //REM
    WMSleepStatusREM = 3,
};

@interface WMSleepItemDataModel : NSObject

/// 睡眠状态
@property (nonatomic, assign) WMSleepStatusType sleep_status;
/// 持续时长（分钟）
@property (nonatomic, assign) NSInteger duration;
/// 时间戳（毫秒）
@property (nonatomic, assign) NSInteger datestamp;

@end

@interface WMSleepDataModel : NSObject

/// 日期时间戳
@property (nonatomic, assign) NSInteger dateStamp;
/// 入睡时间时间戳
@property (nonatomic, assign) NSInteger bed_time;
/// 起床时间时间戳
@property (nonatomic, assign) NSInteger get_up_time;
/// 睡眠时长（分钟）
@property (nonatomic, assign) NSInteger total_sleep_minutes;
/// 睡眠类型 0：白天睡眠， 1：夜晚睡眠
@property (nonatomic, assign) NSInteger sleepType;
/// 清醒时长（分钟）
@property (nonatomic, assign) NSInteger awake_sleep_minutes;
/// 浅睡时长（分钟）
@property (nonatomic, assign) NSInteger light_sleep_minutes;
/// 深睡时长（分钟）
@property (nonatomic, assign) NSInteger deep_sleep_minutes;
/// 眼动时长（分钟）
@property (nonatomic, assign) NSInteger rem_sleep_minutes;
/// 清醒次数
@property (nonatomic, assign) NSInteger awake_count;
/// 浅睡次数
@property (nonatomic, assign) NSInteger light_sleep_count;
/// 深睡次数
@property (nonatomic, assign) NSInteger deep_sleep_count;
/// 眼动次数
@property (nonatomic, assign) NSInteger rem_sleep_count;
/// 清醒百分比
@property (nonatomic, assign) NSInteger awake_percentage;
/// 浅睡百分比
@property (nonatomic, assign) NSInteger light_sleep_percentage;
/// 深睡百分比
@property (nonatomic, assign) NSInteger deep_sleep_percentage;
/// 眼动百分比
@property (nonatomic, assign) NSInteger rem_sleep_percentage;
/// 睡眠得分
@property (nonatomic, assign) NSInteger sleep_score;

/// 睡眠详情
@property (nonatomic, strong) NSArray<WMSleepItemDataModel *> *items;

@end

NS_ASSUME_NONNULL_END
