//
//  WMCalorieDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时内新增消耗的热量（卡）
@interface WMCalorieDataModel : WMBaseDataModel

/// 消耗热量（卡）
@property (nonatomic, assign) int calorie;

@end

NS_ASSUME_NONNULL_END
