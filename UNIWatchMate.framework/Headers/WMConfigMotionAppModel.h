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

/// 同步运动类型列表
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSArray<NSNumber*> *> *)syncActivityType:(NSArray<NSNumber*> *)types;

/// 获取运动类型列表
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSArray<NSNumber*> *> *)wm_getActivityTypes;

@end

NS_ASSUME_NONNULL_END
