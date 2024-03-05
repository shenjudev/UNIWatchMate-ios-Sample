//
//  WMHeartRateAlertModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMHeartRateAlertModel : NSObject

/// 是否启动预警功能的开关。
@property (nonatomic, assign) BOOL isAlertEnabled;
/// 预警的心率阈值。
@property (nonatomic, assign) NSInteger alertThreshold;

@end

NS_ASSUME_NONNULL_END
