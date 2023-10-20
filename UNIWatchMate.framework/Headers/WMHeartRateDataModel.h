//
//  WMHeartRateDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每5分钟实时心率（5分钟内仅记录最后一次（次/分））；
@interface WMHeartRateDataModel : WMBaseDataModel

/// 实时心率（5分钟内仅记录最后一次（次/分））；
@property (nonatomic, assign) int heartRate;

@end

NS_ASSUME_NONNULL_END
