//
//  WMActivityTimeDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时持续活动的时长（秒）
@interface WMActivityTimeDataModel : WMBaseDataModel

/// 活动时长（秒）
@property (nonatomic, assign) int activityTime;

@end

NS_ASSUME_NONNULL_END
