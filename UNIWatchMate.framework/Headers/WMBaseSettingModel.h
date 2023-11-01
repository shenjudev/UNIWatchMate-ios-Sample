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

/// 订阅配置（接收设备端修改配置）
@property (nonatomic, strong) RACSignal<ObjectType> *model;
/// 保存了最新的配置信息（设备端、APP修改配置成功时更新数据）
@property (nonatomic, strong, readonly) ObjectType modelValue;

/// APP修改配置
/// - Parameter model: 配置
- (RACSignal<ObjectType> *)setConfigModel:(ObjectType)model;

/// APP读取配置
- (RACSignal<ObjectType> *)getConfigModel;

@end

NS_ASSUME_NONNULL_END
