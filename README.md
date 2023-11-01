
# UNIWatchMate
UNIWatchMate智能手表的接口框架，负责与手表设备通信等功能的封装，向上提供给App操作智能手表的相关接口，向下可以对接其他手表的SDK。

  
# 注意事项：
 1. 以 `pod` 方式引入三方库时，由于 `SJWatchLib` 引用了 `RXSwift`，在 `Debug` 模式运行 demo 时会崩溃。请参照 demo 中的 `Podfile`，需要添加如下代码：
```
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          if config.name == "Debug"
            config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = []
          end
        end
      end
    end
 ```
 2. `opencv2.framework` 需要从 opencv 官网下载，建议支持版本为 3.4.13 及以上。  
   下载地址:  
     - https://opencv.org/releases/  
     - https://frame-public.oss-cn-beijing.aliyuncs.com/shenju/opencv2.framework/opencv2.framework.zip  
 3. demo和framework均不支持模拟器，请使用手机调试
 4. 主要framework相关说明
  - UNIWatchMate.framework：接口层api，应用调用的是此接口层
  - SJWatchLib.framework：绅聚设备对UNIWatchMate.framework接口层的实现
 5. Sample里面没有展示的功能，都是不可用状态

-------------------------------------------------------------------------------------------------------------------------
# 安装

1. 引入UNIWatchMate.framework(Embed & Sign)、SJWatchLib.framework(Embed & Sign)、h264encoder.framework(Embed & Sign)、opencv2.framework(需要按照最前面的说明去下载)    
2. pod引入以下：
```
  pod 'YYCategories','1.0.4'
  pod "ReactiveObjC",'3.1.1'
  pod 'RxSwift','6.6.0'
  pod 'RxCocoa','6.6.0'
  pod 'PromiseKit','8.1.1'
  pod 'HandyJSON','5.0.2'
  pod 'SwiftyJSON','5.0.1'
```
# 用法
  - 使用`WMManager`进行初始化、扫描、搜索、回连设备，此时会返回一个`RACSignal<WMPeripheral *>`对象。
  - 使用`WMPeripheral`进行一系列设备支持的动作。
## 1. 初始化
  调用‘WMManager’的registerWatchMate注册要使用的设备操作对象，不同的厂商可能有不同的对象，下面代码
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[WMManager sharedInstance] registerWatchMate:[SJWatchFind sharedInstance]];

     如果想使用log：
    [[SJLogInfo sharedInstance] registerLevel: @"DEBUG"];
    [[WMLog sharedInstance] registerLogInfo:[SJLogInfo sharedInstance]];
    [[WMLog sharedInstance].log subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"SJLogInfo %@",x);
    }]; 

  }
```
## 2. 扫描设备

以下三种方式都会得到 WMPeripheral 对象，并且连接不同的设备是不同的对象，后面的所有业务都用这个WMPeripheral进行操作

### 2.1 通过二维码方式扫描
```
code 是二维码里的信息
[[[WMManager sharedInstance] findWatchFromQRCode:code] subscribeNext:^(WMPeripheral * _Nullable x) {
 //x是二维码对应的设备

    } error:^(NSError * _Nullable error) {
        
    }];

```

### 2.2 通过mac地址（回连）
```
WMPeripheralTargetModel *model = [[WMPeripheralTargetModel alloc]init];
model.type = UNIWPeripheralFormTypeMac;
model.name = @"";
model.mac = mac;

[[[WMManager sharedInstance] findWatchFromTarget:model product:@"OSW-802N"] subscribeNext:^(WMPeripheral * _Nullable x) {
        @strongify(self);
        [self bindDevice:x];
    } error:^(NSError * _Nullable error) {
 }]; 
```

### 2.3 通过产品类型搜索
```
[[[WMManager sharedInstance] findWatchFromSearch:@"OSW-802N"] subscribeNext:^(WMPeripheral * _Nullable x) {
        //x是产品类型对应的设备

    } error:^(NSError * _Nullable error) {
        
    }];

```

## 2.6 WMPeripheral接口说明
```
@interface WMPeripheral : NSObject

/// 连接的目标设备
@property (nonatomic, strong) WMPeripheralTargetModel *target;
/// 设备连接
@property (nonatomic, strong) WMConnectModel *connect;
/// 设备信息
@property (nonatomic, strong) WMDeviceInfoModel *infoModel;
/// 功能设置
@property (nonatomic, strong) WMSettingsModel *settings;
/// 设备应用
@property (nonatomic, strong) WMAppsModel *apps;
/// 数据同步
@property (nonatomic, strong) WMDatasSyncModel *datasSync;

@end
```
- WMConnectModel.h: 设备连接相关接口
- WMDeviceInfoModel.h: 设备信息及相关接口，获取设备信息、电量等
- WMSettingsModel.h: 功能设置相关接口：运动目标、计量单位、个人信息、语言、喝水提醒、久坐提醒、时间、开关、app视图、睡眠
- WMAppsModel.h: 设备应用接口：表盘、文件传输、闹钟、通讯录、天气、运动项目配置、心率、查找、相机
- WMDatasSyncModel: 数据同步接口：步数、活动热量、活动时长、活动距离、实时心率、心率统计、血氧、运动小结

***下面举几个例子，其它接口参考demo及相关头文件，里面有详细注释, `x`是`WMPeripheral`的对象***

### 2.6.1 连接设备
```
[[x.connect.isConnected timeout:20 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSNumber * _Nullable x) {
      BOOL isConnected = [x boolValue];
    //isConnected ? @"已连接":@"未连接"
} error:^(NSError * _Nullable error) {

}];
```

### 2.6.2 断开连接
```
[x.connect disconnect];
```
### 2.6.3 设备电量
```
///主动获取设备电量
-(void)getBattery{
    @weakify(self);
    [[[[[WatchManager sharedInstance] currentValue] infoModel] wm_getBattery] subscribeNext:^(WMDeviceBatteryModel * _Nullable x) {
        @strongify(self);
        self.battery.text = [NSString stringWithFormat:@"battery: %d%%  %@",x.battery,x.isCharging == YES ? @"charging":@"not charging"];
        } error:^(NSError * _Nullable error) {
            
        }];
}

///监听设备电量
-(void)listenBattery{
    @weakify(self);
    [[[[[WatchManager sharedInstance] currentValue] infoModel] battery] subscribeNext:^(WMDeviceBatteryModel * _Nullable x) {
        @strongify(self);
        self.battery.text = [NSString stringWithFormat:@"battery: %d%%  %@",x.battery,x.isCharging == YES ? @"charging":@"not charging"];
        } error:^(NSError * _Nullable error) {
            
        }];
}
```

# Version 1.0.1

## v1.0.1(2023-11-01)
1. Modified the search feature to locate devices based on device model and Bluetooth name.
2. Added functionality for managing contacts and emergency contacts.
3. Introduced the ability to delete and install sport activities.
4. Added a weather feature.
5. Included configurations for sedentary reminders, hydration reminders, and heart rate monitoring.
6. Introduced "Find My Phone" and "Stop Find My Phone" functions.
7. Note: Compatibility with firmware version 1.0.1 231101 or later is required.

   
## 2023-10-23
优化设备搜索
