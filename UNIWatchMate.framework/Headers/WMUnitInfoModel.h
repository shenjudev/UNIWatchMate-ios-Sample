//
//  WMUnitInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 长度单位
typedef NS_ENUM(NSInteger, LengthUnit) {
    /// 公里
    LengthUnitKM,
    /// 英里
    LengthUnitMILE
};
/// 重量单位
typedef NS_ENUM(NSInteger, WeightUnit) {
    /// 千克
    WeightUnitKG,
    /// 磅
    WeightUnitLB
};
/// 温度单位
typedef NS_ENUM(NSInteger, TemperatureUnit) {
    /// 摄氏度
    TemperatureUnitCELSIUS,
    /// 华氏度
    TemperatureUnitFAHRENHEIT
};
/// 时间格式
typedef NS_ENUM(NSInteger, TimeFormat) {
    /// 12小时制
    TimeFormatTWELVE_HOUR,
    /// 24小时制
    TimeFormatTWENTY_FOUR_HOUR
};


/// 计量单位设置
@interface WMUnitInfoModel : NSObject

/// 长度单位（none，表示不设置）
@property (nonatomic, assign) LengthUnit lengthUnit;
/// 重量单位（none，表示不设置）
@property (nonatomic, assign) WeightUnit weightUnit;
/// 温度单位（none，表示不设置）
@property (nonatomic, assign) TemperatureUnit temperatureUnit;
/// 时间格式（none，表示不设置）
@property (nonatomic, assign) TimeFormat timeFormat;

@end

NS_ASSUME_NONNULL_END
