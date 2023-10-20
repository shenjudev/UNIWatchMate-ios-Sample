//
//  WMDistanceDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每小时内新增的距离（米）
@interface WMDistanceDataModel : WMBaseDataModel

/// 新增距离（米）
@property (nonatomic, assign) int distance;

@end

NS_ASSUME_NONNULL_END
