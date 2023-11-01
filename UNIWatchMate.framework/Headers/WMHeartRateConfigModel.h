//
//  WMHeartRateConfigModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/10/30.
//

#import <Foundation/Foundation.h>
#import "WMHeartRateAlertModel.h"
#import "WMHeartRateRangeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateConfigModel : NSObject

/// 是否自动测量心率
@property (nonatomic, assign) BOOL isAutoMeasure;
/// 最大心率（通过年龄和最大心率计算心率区间）
@property (nonatomic, assign) NSInteger maxHeartRate;
/// 运动心率提醒
@property (nonatomic, strong) WMHeartRateAlertModel *exerciseAlert;
/// 静息心率提醒
@property (nonatomic, strong) WMHeartRateAlertModel *restingAlert;

/// 获取心率区间
- (WMHeartRateRangeModel *)heartRateRangeModel;

@end

NS_ASSUME_NONNULL_END
