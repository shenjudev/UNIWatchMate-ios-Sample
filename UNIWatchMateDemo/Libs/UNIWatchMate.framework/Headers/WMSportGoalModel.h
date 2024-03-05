//
//  WMSportGoalModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 运动目标设置
@interface WMSportGoalModel : NSObject

/// 步数
@property (nonatomic, assign) NSInteger steps;

/// 卡路里
@property (nonatomic, assign) double calories;

/// 距离
@property (nonatomic, assign) double distance;

/// 活动时长
@property (nonatomic, assign) long activityDuration;

@end

NS_ASSUME_NONNULL_END
