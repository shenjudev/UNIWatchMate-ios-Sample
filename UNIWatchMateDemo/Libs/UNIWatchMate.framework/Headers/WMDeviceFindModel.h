//
//  WMDeviceFindModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMDeviceFindModel : NSObject

/// 响铃次数
@property (nonatomic, assign) NSInteger count;

/// 响铃时长（单位秒）
@property (nonatomic, assign) NSInteger timeSeconds;

@end

NS_ASSUME_NONNULL_END
