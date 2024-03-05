//
//  WMBaseDataModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMBaseDataModel : NSObject

/// 运动开始时间戳
@property (nonatomic, assign) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END

@interface WMBaseByDayDataModel<__covariant ObjectType> : NSObject

/// 运动开始时间戳（精确到天）
@property (nonatomic, assign) NSTimeInterval timestamp;

/// 本天内的所有数据
@property (nonatomic, strong) NSArray<WMBaseDataModel *> * _Nullable datas;

@end
