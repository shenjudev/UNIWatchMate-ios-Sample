//
//  WMSleepDataSyncModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/11/28.
//

#import "WMBaseDataSyncModel.h"
#import "WMSleepDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMSleepDataSyncModel : NSObject

/// 同步睡眠数据
/// - Parameter startTime: 从什么时候开始同步数据
- (RACSignal<NSArray<WMSleepDataModel *>* > *)syncDataWithStartTime:(NSTimeInterval)startTime;

@end

NS_ASSUME_NONNULL_END
