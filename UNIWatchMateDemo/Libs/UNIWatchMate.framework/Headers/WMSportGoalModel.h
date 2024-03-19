//
//  WMSportGoalModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 运动目标设置 （Moving goal setting）
@interface WMSportGoalModel : NSObject

/// 步数 （Step number）
@property (nonatomic, assign) NSInteger steps;

/// 卡路里 （calorie）
@property (nonatomic, assign) double calories;

/// 距离 （distance）
@property (nonatomic, assign) double distance;

/// 活动时长 （Activity duration）
@property (nonatomic, assign) long activityDuration;

@end

NS_ASSUME_NONNULL_END
