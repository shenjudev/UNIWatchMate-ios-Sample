//
//  WMStepDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时步数数据
@interface WMStepDataModel : WMBaseDataModel

/// 步数
@property (nonatomic, assign) int steps;

@end

NS_ASSUME_NONNULL_END
