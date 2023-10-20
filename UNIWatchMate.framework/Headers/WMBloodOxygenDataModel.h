//
//  WMBloodOxygenDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import "WMBaseDataModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 每5分钟产生的饱和度，5分钟内仅记录最后一次（0-100%）
@interface WMBloodOxygenDataModel : WMBaseDataModel

@end

NS_ASSUME_NONNULL_END
