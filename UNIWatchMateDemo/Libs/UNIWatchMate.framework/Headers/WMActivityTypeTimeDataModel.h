//
//  WMActivityTypeTimeDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/30.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每类运动的运动时长
@interface WMActivityTypeTimeDataModel : WMBaseDataModel

/// 活动时长（秒）
@property (nonatomic, assign) NSInteger activityTime;

/// 活动类型
@property (nonatomic, assign) NSInteger activityType;

@end

NS_ASSUME_NONNULL_END
