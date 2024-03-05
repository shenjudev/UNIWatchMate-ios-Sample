//
//  WMActivityDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>
#import "WMSportDataType.h"
#import "WMActivityType.h"
#import "WMHeartRateDataModel.h"
#import "WMStepDataModel.h"
#import "WMCalorieDataModel.h"
#import "WMDistanceDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每次运动过的运动小结数据；
@interface WMActivityDataModel : NSObject

// 训练开始日期
@property (assign, nonatomic) NSInteger timestamp;
// 训练开始时间戳(毫秒)
@property (assign, nonatomic) NSInteger ts_start;
// 训练结束时间戳(毫秒)
@property (assign, nonatomic) NSInteger ts_end;
// 训练时长
@property (assign, nonatomic) NSInteger duration;
// 运动类型
@property (assign, nonatomic) NSInteger sport_id;
// 训练类型
@property (assign, nonatomic) NSInteger sport_type;
// 步数
@property (assign, nonatomic) NSInteger step;
// 卡路里
@property (assign, nonatomic) double calories;
// 距离
@property (assign, nonatomic) NSInteger distance;
// 活动时长
@property (assign, nonatomic) NSInteger act_time;
// 最大心率
@property (assign, nonatomic) NSInteger max_hr;
// 平均心率
@property (assign, nonatomic) NSInteger avg_hr;
// 最小心率
@property (assign, nonatomic) NSInteger min_hr;
// 心率 -- 极限时长
@property (assign, nonatomic) NSInteger hr_limit_time;
// 心率 -- 无氧耐力时长
@property (assign, nonatomic) NSInteger hr_anaerobic;
// 心率 -- 有氧耐力时长
@property (assign, nonatomic) NSInteger hr_aerobic;
// 心率 -- 燃脂时长
@property (assign, nonatomic) NSInteger hr_fat_burning;
// 心率 -- 热身时长
@property (assign, nonatomic) NSInteger hr_warm_up;
// 最大步频
@property (assign, nonatomic) NSInteger max_step_speed;
// 最小步频
@property (assign, nonatomic) NSInteger min_step_speed;
// 平均步频
@property (assign, nonatomic) NSInteger avg_step_speed;
// 最快配速
@property (assign, nonatomic) NSInteger fast_pace;
// 最慢配速
@property (assign, nonatomic) NSInteger slowest_pace;
// 平均配速
@property (assign, nonatomic) NSInteger avg_pace;
// 最快速度
@property (assign, nonatomic) NSInteger fast_speed;
// 最慢速度
@property (assign, nonatomic) NSInteger slowest_speed;
// 平均速度
@property (assign, nonatomic) NSInteger avg_speed;

/// 10秒心率
@property (strong, nonatomic) NSArray<WMHeartRateDataModel *> *rate_items;
/// 10秒步数
@property (strong, nonatomic) NSArray<WMStepDataModel *> *step_items;
/// 10秒热量
@property (strong, nonatomic) NSArray<WMCalorieDataModel *> *calories_items;
/// 10秒距离
@property (strong, nonatomic) NSArray<WMDistanceDataModel *> *distance_items;

@end

NS_ASSUME_NONNULL_END
