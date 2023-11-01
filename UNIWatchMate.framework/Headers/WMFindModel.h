//
//  WMFindModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "WMPeripheral.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , WMPeripheralFormType){
    UNIWPeripheralFormTypeScanQR NS_SWIFT_NAME(scanQR),
    UNIWPeripheralFormTypeSearch NS_SWIFT_NAME(search),
    UNIWPeripheralFormTypeMac NS_SWIFT_NAME(mac),
};

/// 需要连接的设备
@interface WMPeripheralTargetModel : NSObject

/// 连接入口
@property (nonatomic, assign) WMPeripheralFormType type;
/// 设备Mac地址
@property (nonatomic, strong) NSString * mac;
/// 设备蓝牙名称
@property (nonatomic, strong) NSString * name;

@end

@interface WMFindModel : NSObject

/// 单例需要子类实现
+ (WMFindModel *)sharedInstance;

/// 通过二维码信息获取一个watch对象
/// - Parameter code: 二维码信息
- (RACSignal<WMPeripheral *> * _Nullable )fromScanQRCode:(NSString *)code;

/// 搜索周围可以用的设备
- (RACSignal<WMPeripheral *> * _Nullable )fromSearch;

/// 停止搜索
- (void)stopSearch;

/// 通过target获取一个watch对象
/// - Parameter target: target 包含mac，name等信息
- (RACSignal<WMPeripheral *> * _Nullable )fromTarget:(WMPeripheralTargetModel *)target;

/// 是否支持某个产品
/// - Parameter product: 产品型号
- (BOOL)isEnabledForProduct:(NSString *)product;

@end

NS_ASSUME_NONNULL_END
