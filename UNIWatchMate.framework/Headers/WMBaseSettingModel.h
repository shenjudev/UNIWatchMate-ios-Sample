//
//  WMBaseSettingModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMSupportProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMBaseSettingModel<__covariant ObjectType> : NSObject <WMSupportProtocol>

/// 订阅配置状态
@property (nonatomic, strong) RACSignal<ObjectType> *model;
@property (nonatomic, strong, readonly) ObjectType modelValue;

/// 设置配置状态
/// - Parameter model: 配置状态
- (RACSignal<ObjectType> *)setConfigModel:(ObjectType)model;

/// 主动重新获取配置状态
- (RACSignal<ObjectType> *)getConfigModel;

@end

NS_ASSUME_NONNULL_END
