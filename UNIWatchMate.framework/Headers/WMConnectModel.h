//
//  WMConnectModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
NS_ASSUME_NONNULL_BEGIN

@interface WMConnectModel : NSObject

/// 可订阅对象，设备是否连接
@property (nonatomic, strong) RACSignal<NSNumber *> *isConnected;
@property (nonatomic, assign, readonly) BOOL isConnectedValue;

/// 可订阅对象，设备是否初始化完成，可以进行数据交互
@property (nonatomic, strong) RACSignal<NSNumber *> *isReady;
@property (nonatomic, assign, readonly) BOOL isReadyValue;

/// 连接
- (void)connect;

/// 断开连接
- (void)disconnect;

/// 恢复出厂（解绑），解绑结果BOOL
- (RACSignal<NSNumber *> *)restoreFactory;

@end

NS_ASSUME_NONNULL_END
