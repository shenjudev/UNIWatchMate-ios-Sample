//
//  WMDatasSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMStepDataSyncModel.h"
#import "WMCalorieDataSyncModel.h"
#import "WMActivityTimeDataSyncModel.h"
#import "WMDistanceDataSyncModel.h"
#import "WMHeartRateDataSyncModel.h"
#import "WMHeartRateStatisticsDataSyncModel.h"
#import "WMBloodOxygenDataSyncModel.h"
#import "WMActivityDataSyncModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 数据同步
@interface WMDatasSyncModel : NSObject

/// 同步步数数据
@property (nonatomic, strong) WMStepDataSyncModel *syncStep;
/// 活动热量数据
@property (nonatomic, strong) WMCalorieDataSyncModel *syncCalorie;
/// 同步活动时长数据
@property (nonatomic, strong) WMActivityTimeDataSyncModel *syncActivityTime;
/// 同步活动距离数据
@property (nonatomic, strong) WMDistanceDataSyncModel *syncDistance;
/// 同步实时心率数据
@property (nonatomic, strong) WMHeartRateDataSyncModel *syncHeartRate;
/// 同步心率统计数据
@property (nonatomic, strong) WMHeartRateStatisticsDataSyncModel *syncHeartRateStatistics;
/// 同步血氧数据
@property (nonatomic, strong) WMBloodOxygenDataSyncModel *syncBloodOxygen;
/// 同步运动小结数据
@property (nonatomic, strong) WMActivityDataSyncModel *syncActivity;

@end

NS_ASSUME_NONNULL_END
