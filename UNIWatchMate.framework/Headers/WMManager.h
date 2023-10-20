//
//  WMManager.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMFindModel.h"
#import "WMPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

@interface WMManager : NSObject

+ (instancetype)sharedInstance;

/// 注册SDK
/// - Parameter watchMate: WMFindModel 的子类
- (void)registerWatchMate:(WMFindModel *)watchMate;

/// 通过二维码信息，获取一个设备对象（回调一次）
/// - Parameter code: 二维码信息
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromQRCode:(NSString *)code;

/// 通过产品类型，搜索附近设备（回调多次，需要主动停止搜索）
/// - Parameter product: 产品类型
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromSearch:(NSString *)product;

/// 用与回连设备，通过mac和产品型号，获取一个设备对象（回调一次）
/// - Parameters:
///   - target: 目标设备（mac, name等）
///   - product: 产品类型
- (RACSignal<WMPeripheral *> * _Nullable )findWatchFromTarget:(WMPeripheralTargetModel *)target product:(NSString *)product;

/// 停止搜索
/// - Parameter product: 产品类型
- (void)stopSearch:(NSString *)product;

@end

NS_ASSUME_NONNULL_END
