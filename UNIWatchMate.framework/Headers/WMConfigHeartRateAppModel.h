//
//  WMConfigHeartRateAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMHeartRateRangeModel.h"
#import "WMHeartRateAlertModel.h"
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMConfigHeartRateAppModel : NSObject<WMSupportProtocol>

/// 订阅是否为自动测量
@property (nonatomic, strong) RACSignal<NSNumber *> *isAuto;
@property (nonatomic, assign, readonly) BOOL isAutoValue;

/// 心率区间
@property (nonatomic, strong) RACSignal<WMHeartRateRangeModel *> *heartRateRange;
@property (nonatomic, strong, readonly) WMHeartRateRangeModel *heartRateRangeValue;

/// 运动心率预警
@property (nonatomic, strong) RACSignal<WMHeartRateAlertModel *> *activityHeartRateAlert;
@property (nonatomic, strong, readonly) WMHeartRateAlertModel *activityHeartRateAlertValue;

/// 静息心率预警
@property (nonatomic, strong) RACSignal<WMHeartRateAlertModel *> *restingHeartRateAlert;
@property (nonatomic, strong, readonly) WMHeartRateAlertModel *restingHeartRateAlertValue;

/// 设置是否自动测量
/// - Parameter isAuto: BOOL 是否自动测量
- (RACSignal<NSNumber *> *)configIsAuto:(NSNumber *)isAuto;

/// 通过最大心率设置心率区间
/// - Parameter max: 最大心率
- (RACSignal<WMHeartRateRangeModel *> *)configHeartRateRange:(NSInteger)max;

/// 设置运动心率预警
/// - Parameter alert: 心率预警数据
- (RACSignal<WMHeartRateAlertModel *> *)configActivityHeartRateAlert:(WMHeartRateAlertModel *)alert;

/// 设置静息心率预警
/// - Parameter alert: 心率预警数据
- (RACSignal<WMHeartRateAlertModel *> *)configRestingHeartRateAlert:(WMHeartRateAlertModel *)alert;

@end

NS_ASSUME_NONNULL_END
