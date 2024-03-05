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

/// 固定运动个数列表改变
@property (nonatomic, strong) RACSignal<NSArray<NSNumber*> *> *fixedTypes;
/// 可变运动个数列表改变
@property (nonatomic, strong) RACSignal<NSArray<NSNumber*> *> *variableTypes;


/// 同步固定运动个数列表
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSNumber *> *)syncFixedActivityType:(NSArray<NSNumber*> *)types;

/// 同步可变运动个数列表
/// - Parameter type: 运动列表（Int值）
- (RACSignal<NSNumber *> *)syncVariableActivityType:(NSArray<NSNumber*> *)types;

/// 获取固定运动列表
- (RACSignal<NSArray<NSNumber*> *> *)getFixedActivityTypes;

/// 获取可变运动列表
- (RACSignal<NSArray<NSNumber*> *> *)getVariableActivityTypes;

/// 获取设备支持所有运动
- (RACSignal<NSArray<NSNumber*> *> *)getSupportedActivityTypes;

@end

NS_ASSUME_NONNULL_END
