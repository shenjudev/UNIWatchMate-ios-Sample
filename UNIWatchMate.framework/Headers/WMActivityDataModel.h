//
//  WMActivityDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>
#import "WMSportDataType.h"
#import "WMActivityType.h"

NS_ASSUME_NONNULL_BEGIN

/// 运动数据
@interface WMSportDataModel : NSObject

/// 运动数据类型
@property (nonatomic, assign) WMSportDataType sportDataType;
/// 统计结果（不同类别含义不同）
@property (nonatomic, assign) double value;

@end

/// 每次运动过的运动小结数据；
@interface WMActivityDataModel : NSObject

/// 活动类型
@property (nonatomic, assign) NSInteger activityType;

/// 运动统计数据
@property (nonatomic, strong) NSArray<WMSportDataModel *> *sportDatas;

@end

NS_ASSUME_NONNULL_END
