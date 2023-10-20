//
//  WMConfigMotionAppModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import "WMSportTypeModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMConfigMotionAppModel : NSObject<WMSupportProtocol>

/// 当前有的运动（类型Int值）
@property (nonatomic, strong) RACSignal<NSArray<NSNumber*> *> *activityTypes;
@property (nonatomic, strong, readonly) NSArray<NSNumber*> *activityTypesValue;

/// 删除运动
/// - Parameter type: 运动类别（Int值）
- (RACSignal<NSArray<NSNumber*> *> *)deleteActivityType:(NSNumber *)type;

/// 添加运动
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSArray<NSNumber*> *> *)addActivityType:(NSNumber *)type;

@end

NS_ASSUME_NONNULL_END
