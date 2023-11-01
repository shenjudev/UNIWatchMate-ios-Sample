//
//  WeatherCreateHelper.m
//  UNIWatchMateDemo
//
//  Created by 孙强 on 2023/10/31.
//

#import "WeatherCreateHelper.h"
typedef NS_ENUM(NSInteger,WeatherConditionDay){
    WeatherConditionDaySunny = 32,
    WeatherConditionDayPartlyCloudy = 30,
    WeatherConditionDayScatteredThunderstorms = 38,
    WeatherConditionDayScatteredShowers = 39,
    WeatherConditionDayHeavyRain = 40,
    WeatherConditionDayScatteredSnowShowers = 41,
    WeatherConditionDayHeavySnow = 42,
    WeatherConditionDayMostlyCloudy = 28,
    WeatherConditionDayHot = 36,
    WeatherConditionDayFairMostlySunny = 34,
    WeatherConditionDayUnknown = -1,
    WeatherConditionDayNotAvailable = 44
};
typedef NS_ENUM(NSInteger,WeatherConditionNight){
    WeatherConditionNightScatteredThunderstorms = 47,
    WeatherConditionNightScatteredShowers = 45,
    WeatherConditionNightClear = 31,
    WeatherConditionNightFairMostlyClear = 33,
    WeatherConditionNightPartlyCloudy = 29,
    WeatherConditionNightMostlyCloudy = 27,
    WeatherConditionNightScatteredSnowShowers = 46,
    WeatherConditionNightUnknown = -1,
    WeatherConditionNightNotAvailable = 44
};
typedef NS_ENUM(NSInteger, WeatherCondition){
    TORNADO = 0,
    TROPICAL_STORM,
    HURRICANE,
    STRONG_STORMS,
    THUNDERSTORMS = 4,
    SHOWERS = 11,
    SCATTERED_THUNDERSTORMS_NIGHT = 47,
    SCATTERED_SHOWERS_NIGHT = 45,
    ISOLATED_THUNDERSTORMS = 37,
    SCATTERED_THUNDERSTORMS_DAY = 38,
    SCATTERED_SHOWERS_DAY = 39,
    RAIN_SNOW = 5,
    WINTRY_MIX = 7,
    SLEET = 18,
    HAIL = 17,
    RAIN_SLEET = 6,
    MIXED_RAIN_AND_HAIL = 35,
    FRIGID_ICE_CRYSTALS = 25,
    FREEZING_DRIZZLE = 8,
    DRIZZLE = 9,
    FREEZING_RAIN = 10,
    RAIN = 12,
    FLURRIES = 13,
    SNOW_SHOWERS = 14,
    BLOWING_DRIFTING_SNOW = 15,
    SNOW = 16,
    SCATTERED_SNOW_SHOWERS_NIGHT = 46,
    SCATTERED_SNOW_SHOWERS_DAY = 41,
    HEAVY_SNOW = 42,
    BLIZZARD = 43,
    BLOWING_DUST_SANDSTORM = 19,
    FOGGY = 20,
    HAZE = 21,
    SMOKE = 22,
    CLOUDY = 26,
    PARTLY_CLOUDY_DAY = 30,
    HEAVY_RAIN = 40,
    CLEAR_NIGHT = 31,
    FAIR_MOSTLY_CLEAR = 33,
    PARTLY_CLOUDY_NIGHT = 29,
    MOSTLY_CLOUDY_NIGHT = 27,
    SUNNY_DAY = 32,
    HOT = 36,
    MOSTLY_CLOUDY_DAY = 28,
    FAIR_MOSTLY_SUNNY = 34,
    UNKNOWN = -1,
    NOT_AVAILABLE = 44,
    BREEZY = 23,
    WINDY = 24
};

WeatherCondition getRandomWeatherCondition(void) {
    WeatherCondition allConditions[] = {
        TORNADO, TROPICAL_STORM, HURRICANE, STRONG_STORMS, THUNDERSTORMS,
        SHOWERS, SCATTERED_THUNDERSTORMS_NIGHT, SCATTERED_SHOWERS_NIGHT,
        ISOLATED_THUNDERSTORMS, SCATTERED_THUNDERSTORMS_DAY, SCATTERED_SHOWERS_DAY,
        RAIN_SNOW, WINTRY_MIX, SLEET, HAIL, RAIN_SLEET, MIXED_RAIN_AND_HAIL,
        FRIGID_ICE_CRYSTALS, FREEZING_DRIZZLE, DRIZZLE, FREEZING_RAIN, RAIN,
        FLURRIES, SNOW_SHOWERS, BLOWING_DRIFTING_SNOW, SNOW, SCATTERED_SNOW_SHOWERS_NIGHT,
        SCATTERED_SNOW_SHOWERS_DAY, HEAVY_SNOW, BLIZZARD, BLOWING_DUST_SANDSTORM, FOGGY,
        HAZE, SMOKE, CLOUDY, PARTLY_CLOUDY_DAY, HEAVY_RAIN, CLEAR_NIGHT,
        FAIR_MOSTLY_CLEAR, PARTLY_CLOUDY_NIGHT, MOSTLY_CLOUDY_NIGHT, SUNNY_DAY,
        HOT, MOSTLY_CLOUDY_DAY, FAIR_MOSTLY_SUNNY, UNKNOWN, NOT_AVAILABLE,
        BREEZY, WINDY
    };

    NSUInteger count = sizeof(allConditions) / sizeof(WeatherCondition);
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)count);
    return allConditions[randomIndex];
}
WeatherConditionDay getRandomDayWeatherCondition(void) {
    WeatherConditionDay allDayConditions[] = {
        WeatherConditionDaySunny, WeatherConditionDayPartlyCloudy, WeatherConditionDayScatteredThunderstorms,
        WeatherConditionDayScatteredShowers, WeatherConditionDayHeavyRain, WeatherConditionDayScatteredSnowShowers,
        WeatherConditionDayHeavySnow, WeatherConditionDayMostlyCloudy, WeatherConditionDayHot,
        WeatherConditionDayFairMostlySunny, WeatherConditionDayUnknown, WeatherConditionDayNotAvailable
    };

    NSUInteger count = sizeof(allDayConditions) / sizeof(WeatherConditionDay);
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)count);
    return allDayConditions[randomIndex];
}

WeatherConditionNight getRandomNightWeatherCondition(void) {
    WeatherConditionNight allNightConditions[] = {
        WeatherConditionNightScatteredThunderstorms, WeatherConditionNightScatteredShowers, WeatherConditionNightClear,
        WeatherConditionNightFairMostlyClear, WeatherConditionNightPartlyCloudy, WeatherConditionNightMostlyCloudy,
        WeatherConditionNightScatteredSnowShowers, WeatherConditionNightUnknown, WeatherConditionNightNotAvailable
    };

    NSUInteger count = sizeof(allNightConditions) / sizeof(WeatherConditionNight);
    NSUInteger randomIndex = arc4random_uniform((u_int32_t)count);
    return allNightConditions[randomIndex];
}
NSString *NSStringFromWeatherCondition(WeatherCondition condition) {
    switch (condition) {
        case TORNADO:
            return @"龙卷风";
        case TROPICAL_STORM:
            return @"热带风暴";
        case HURRICANE:
            return @"飓风";
        case STRONG_STORMS:
            return @"风暴";
        case BREEZY:
            return @"微风";
        case WINDY:
            return @"大风";
        case THUNDERSTORMS:
            return @"雷雨";
        case SHOWERS:
            return @"阵雨";
        case SCATTERED_THUNDERSTORMS_NIGHT:
            return @"夜间局部雷阵雨";
        case SCATTERED_SHOWERS_NIGHT:
            return @"夜间零星阵雨";
        case ISOLATED_THUNDERSTORMS:
            return @"局部分包";
        case SCATTERED_THUNDERSTORMS_DAY:
            return @"白天局部雷阵雨";
        case SCATTERED_SHOWERS_DAY:
            return @"白天零星阵雨";
        case RAIN_SNOW:
            return @"雨雪";
        case WINTRY_MIX:
            return @"雨夹雪";
        case SLEET:
            return @"雨雪";
        case HAIL:
            return @"冰雹";
        case RAIN_SLEET:
            return @"雨冰雹";
        case MIXED_RAIN_AND_HAIL:
            return @"雨加冰雹";
        case FRIGID_ICE_CRYSTALS:
            return @"冰珠";
        case FREEZING_DRIZZLE:
            return @"冻毛毛雨";
        case DRIZZLE:
            return @"毛毛雨";
        case FREEZING_RAIN:
            return @"冻雨";
        case RAIN:
            return @"雨天";
        case FLURRIES:
            return @"小雪";
        case SNOW_SHOWERS:
            return @"阵雪";
        case BLOWING_DRIFTING_SNOW:
            return @"风吹雪";
        case SNOW:
            return @"雪";
        case SCATTERED_SNOW_SHOWERS_NIGHT:
            return @"夜间零星阵雪";
        case SCATTERED_SNOW_SHOWERS_DAY:
            return @"白天零星阵雪";
        case HEAVY_SNOW:
            return @"大雪";
        case BLIZZARD:
            return @"暴风雪";
        case BLOWING_DUST_SANDSTORM:
            return @"扬尘、沙暴";
        case FOGGY:
            return @"有雾的";
        case HAZE:
            return @"霾";
        case SMOKE:
            return @"烟雾";
        case CLOUDY:
            return @"多云";
        case PARTLY_CLOUDY_DAY:
            return @"白天局部多云";
        case HEAVY_RAIN:
            return @"暴雨";
        case CLEAR_NIGHT:
            return @"夜间晴天";
        case FAIR_MOSTLY_CLEAR:
            return @"夜间晴时多云";
        case PARTLY_CLOUDY_NIGHT:
            return @"夜间局部多云";
        case MOSTLY_CLOUDY_NIGHT:
            return @"夜间大部分多云";
        case SUNNY_DAY:
            return @"晴天";
        case HOT:
            return @"热";
        case MOSTLY_CLOUDY_DAY:
            return @"白天多云间晴";
        case FAIR_MOSTLY_SUNNY:
            return @"白天晴时多云";
        case UNKNOWN:
            return @"未知";
        case NOT_AVAILABLE:
            return @"无法使用";
        default:
            return @"未知";
    }
}


NSString *NSStringFromTemperatureUnitForWeather(TemperatureUnit temperatureUnit) {
    switch (temperatureUnit) {
        case TemperatureUnitCELSIUS:
            return @"TemperatureUnitCELSIUS";
        case TemperatureUnitFAHRENHEIT:
            return @"TemperatureUnitFAHRENHEIT";
    }
}
NSString *NSStringFromWMWeekForWeather(WMWeek week) {
    switch (week) {
        case WMWeekSunday:
            return @"星期日";
        case WMWeekMonday:
            return @"星期一";
        case WMWeekTuesday:
            return @"星期二";
        case WMWeekWednesday:
            return @"星期三";
        case WMWeekThursday:
            return @"星期四";
        case WMWeekFriday:
            return @"星期五";
        case WMWeekSaturday:
            return @"星期六";
    }
}
@implementation WeatherCreateHelper
+(WMWeatherModel *)generateNew{
    WMWeatherModel *currentWeatherModel = [WMWeatherModel new];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startOfDay = [calendar dateFromComponents:components];
    currentWeatherModel.pubDate = now;

    WMLocationModel * location = [WMLocationModel new];
    location.country = [NSString stringWithFormat:@"国家 %ld",(long)random()%10000];
    location.city = [NSString stringWithFormat:@"城市 %ld",(long)random()%10000];
    currentWeatherModel.location = location;
    NSInteger weatherForecastCount = 7;
    NSMutableArray * weatherForecast = [NSMutableArray new];




    for (int i = 0; i < weatherForecastCount; i++){
        WMWeatherForecastModel *model = [WMWeatherForecastModel new];
        NSInteger lowTemp = (NSInteger)arc4random_uniform(21) - 10; // -10 to 10
        model.lowTemp = lowTemp;
        model.highTemp = arc4random_uniform(21) + 10; // 10 to 30
        model.curTemp = arc4random_uniform((model.highTemp - model.lowTemp + 1)) + model.lowTemp; // lowTemp to highTemp
        model.humidity = arc4random_uniform(101); // 0 to 100
        model.uvIndex = arc4random_uniform(11); // 0 to 10
        model.dayCode =  getRandomDayWeatherCondition();
        model.nightCode = getRandomNightWeatherCondition();
        model.dayDesc = NSStringFromWeatherCondition(model.dayCode);

        model.nightDesc = NSStringFromWeatherCondition(model.dayCode);

        NSDateComponents *nextComponents = [components copy];
        [nextComponents setDay:[components day]+i];
        NSDate *nextDate = [calendar dateFromComponents:nextComponents];

        model.date = nextDate;


        [weatherForecast addObject:model];
    }
    currentWeatherModel.weatherForecast = weatherForecast;

    NSInteger todayWeatherCount = 24;
    NSMutableArray * todayWeather = [NSMutableArray new];


    NSDate *now24 = [NSDate date];
    NSCalendar *calendar24 = [NSCalendar currentCalendar];
    NSDateComponents *components24 = [calendar24 components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:now24];
    [components24 setHour:[components24 hour]];
    [components24 setMinute:[components24 minute]];
    [components24 setSecond:[components24 second]];
    NSDate *currentDate = [calendar24 dateFromComponents:components24];


    for (int i = 0; i < todayWeatherCount; i++){
        WMTodayWeatherModel *model = [WMTodayWeatherModel new];
        model.curTemp = (NSInteger)arc4random_uniform(40) - 10; // -10 to 30
        model.humidity = arc4random_uniform(101); // 0 to 100
        model.uvIndex = arc4random_uniform(11); // 0 to 10
        model.weatheCode = getRandomWeatherCondition();
        model.weatherDesc = NSStringFromWeatherCondition(model.weatheCode);
        NSDateComponents *nextComponents24 = [components24 copy];
        [nextComponents24 setHour:[components24 hour] + i];
        [nextComponents24 setMinute:0];
        [nextComponents24 setSecond:0];
        NSDate *nextDate = [calendar24 dateFromComponents:nextComponents24];
        model.date = nextDate;
        [todayWeather addObject:model];
    }
    currentWeatherModel.todayWeather = todayWeather;

    return  currentWeatherModel;
}
@end
