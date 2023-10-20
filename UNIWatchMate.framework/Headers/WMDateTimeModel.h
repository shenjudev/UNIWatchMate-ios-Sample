//
//  WMDateTimeModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMUnitInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 日期与时间同步信息
@interface WMDateTimeModel : NSObject

/// 当前时间
@property (nonatomic, strong) NSDate *currentDate;
/// 时间格式
@property (nonatomic, assign) TimeFormat timeFormat;

@end

NS_ASSUME_NONNULL_END
