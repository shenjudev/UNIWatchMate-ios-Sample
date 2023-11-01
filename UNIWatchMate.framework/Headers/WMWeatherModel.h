//
//  WMWeatherModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/16.
//

#import <Foundation/Foundation.h>
#import "WMUnitInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WMWeek) {
    WMWeekSunday,      /// 星期日
    WMWeekMonday,      /// 星期一
    WMWeekTuesday,     /// 星期二
    WMWeekWednesday,   /// 星期三
    WMWeekThursday,    /// 星期四
    WMWeekFriday,      /// 星期五
    WMWeekSaturday     /// 星期六
};

/// 天气（weather）
@interface WMWeatherForecastModel : NSObject
/// 最低温度（low temperature）
@property (nonatomic, assign) NSInteger lowTemp;
/// 最高温度（high temperature）
@property (nonatomic, assign) NSInteger highTemp;
/// 当前温度（current temperature）
@property (nonatomic, assign) NSInteger curTemp;
/// 湿度（humidity）
@property (nonatomic, assign) NSInteger humidity;
/// 紫外线指数（ultraviolet index）
@property (nonatomic, assign) NSInteger uvIndex;
/// 白天天气代码（day weather code）
@property (nonatomic, assign) NSInteger dayCode;
/// 夜晚天气代码（night weather code）
@property (nonatomic, assign) NSInteger nightCode;
/// 白天天气描述（day weather description）
@property (nonatomic, strong) NSString *dayDesc;
/// 夜晚天气描述（night weather description）
@property (nonatomic, strong) NSString *nightDesc;
/// 日期（date）
@property (nonatomic, strong) NSDate *date;
@end

/// 今日天气（Today's weather）
@interface WMTodayWeatherModel : NSObject
/// 当前温度（current temperature）
@property (nonatomic, assign) NSInteger curTemp;
/// 湿度（humidity）
@property (nonatomic, assign) NSInteger humidity;
/// 紫外线指数（ultraviolet index）
@property (nonatomic, assign) NSInteger uvIndex;
/// 白天天气代码（day weather code）
@property (nonatomic, assign) NSInteger weatheCode;
/// 白天天气描述（day weather description）
@property (nonatomic, strong) NSString *weatherDesc;
/// 日期（date）
@property (nonatomic, strong) NSDate *date;
@end

/// 地理位置信息（Geographical location）
@interface WMLocationModel : NSObject
/// 国家（country）
@property (nonatomic, strong) NSString *country;
/// 城市（city）
@property (nonatomic, strong) NSString *city;

@end

/// 整体天气信息（Overall weather information）
@interface WMWeatherModel : NSObject
/// 发布时间（publish time）
@property (nonatomic, strong) NSDate *pubDate;
/// 地理位置（location）
@property (nonatomic, strong) WMLocationModel *location;
/// 7天天气预报（weather forecast for 7 days）
@property (nonatomic, strong) NSArray<WMWeatherForecastModel *> *weatherForecast;
/// 今日24小时天气预报(24 hours weather forecast today)
@property (nonatomic, strong) NSArray<WMTodayWeatherModel *> *todayWeather;
@end

NS_ASSUME_NONNULL_END
