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
/// 运动持续时间
@property (nonatomic, assign) NSTimeInterval duration;

@end

NS_ASSUME_NONNULL_END
