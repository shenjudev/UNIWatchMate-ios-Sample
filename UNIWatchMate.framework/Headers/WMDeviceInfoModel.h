//
//  WMDeviceInfoModel.h
//  UNIWatchMate
//
//  Created by t_t on 2023/9/15.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface WMDeviceBaseInfo : NSObject

/// 设备型号
@property (nonatomic, copy) NSString * _Nullable model;
/// 设备MAC地址
@property (nonatomic, copy) NSString * _Nullable macAddress;
/// 设备版本
@property (nonatomic, copy) NSString * _Nullable version;
/// 设备ID
@property (nonatomic, copy) NSString * _Nullable deviceId;
/// 蓝牙名称
@property (nonatomic, copy) NSString * _Nullable bluetoothName;
/// 设备名称
@property (nonatomic, copy) NSString * _Nullable deviceName;

@end

@interface WMDeviceBatteryModel : NSObject

/// 设备电量百分比0~100
@property (nonatomic, assign) NSInteger battery;
/// 设备是否充电
@property (nonatomic, assign) BOOL isCharging;

@end

/// 设备信息
@interface WMDeviceInfoModel : NSObject

/// 设备基本信息
@property (nonatomic, strong) RACSignal<WMDeviceBaseInfo *> *baseinfo;
@property (nonatomic, strong, readonly) WMDeviceBaseInfo * baseinfoValue;

/// 设备电量
@property (nonatomic, strong) RACSignal<WMDeviceBatteryModel *> *battery;
@property (nonatomic, assign, readonly) WMDeviceBatteryModel *batteryValue;

/// 主动获取设备信息
- (RACSignal<WMDeviceBaseInfo *> *)wm_getBaseinfo;

/// 主动获取电量
- (RACSignal<WMDeviceBatteryModel *> *)wm_getBattery;

@end

NS_ASSUME_NONNULL_END
