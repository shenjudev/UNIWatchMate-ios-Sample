//
//  WMWeatherForecastAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMWeatherModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 天气预报
@interface WMWeatherForecastAppModel : NSObject<WMSupportProtocol>

/// 推送天气给设备
/// - Parameter weather: 天气数据
- (RACSignal<NSNumber *> *)pushWeather:(WMWeatherModel *)weather;

@end

NS_ASSUME_NONNULL_END
