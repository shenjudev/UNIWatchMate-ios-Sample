//
//  WMHeartRateStatisticsDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时的最高、最低和平均心率
@interface WMHeartRateStatisticsDataModel : WMBaseDataModel

/// 最高心率
@property (nonatomic, assign) NSInteger highestHeartRate;
/// 最低心率
@property (nonatomic, assign) NSInteger lowestHeartRate;
/// 平均心率
@property (nonatomic, assign) float averageHeartRate;

@end

NS_ASSUME_NONNULL_END
