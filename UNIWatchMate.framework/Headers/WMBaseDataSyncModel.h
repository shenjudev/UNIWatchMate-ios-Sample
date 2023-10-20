//
//  WMBaseDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMBaseDataSyncModel<__covariant ObjectType> : NSObject <WMSupportProtocol>

/// 上次同步时间戳
- (NSTimeInterval)latestSyncTime;

/// 同步数据
/// - Parameter startTime: 从什么时候开始同步数据
- (RACSignal<NSArray<ObjectType>* > *)syncDataWithStartTime:(NSTimeInterval)startTime;

@end

NS_ASSUME_NONNULL_END
