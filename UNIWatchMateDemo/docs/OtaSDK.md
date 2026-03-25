# OTA SDK 使用文档

> 完整示例：[`UNIOTAUsageExample.swift`](../Demo/OtaSdk/UNIOTAUsageExample.swift)

---

## ⚠️ 重要说明

示例代码（`UNIOTAUsageExample.swift`）中使用了 `WMOtherDataDelegate` 和 `WatchManager` 来收发蓝牙数据。**这两者是本 Demo 工程的内部依赖，仅用于演示，不属于 OTA SDK 本身。**

集成到您自己的工程时，**必须将它们替换为您自己的蓝牙数据收发实现**。具体替换方式见下文。

---

## 目录

1. [依赖配置](#依赖配置)
2. [集成步骤](#集成步骤)
3. [替换蓝牙实现](#替换蓝牙实现)
4. [启动 OTA 升级](#启动-ota-升级)
5. [API 速查](#api-速查)
6. [注意事项](#注意事项)

---

## 依赖配置

### Bridging Header

在工程的 Bridging Header 文件中添加：

```objc
#import "OtaSdk/Lib/UNIOTACLFSR.h"
#import "OtaSdk/Lib/UNIOTABtUtils.h"
```

### Podfile

```ruby
pod 'RxSwift'
pod 'RxCocoa'
pod 'PromiseKit'
pod 'SWCompression'
pod 'SwiftyJSON'
```

---

## 集成步骤

### 第一步：声明属性并遵守协议

```swift
import RxSwift

class MyOTAViewController: UIViewController,
                           MTWatchPeripheralDelegate,  // 必须实现：SDK 发送数据时回调
                           MTLogDelegate {             // 必须实现：SDK 日志回调

    let mtWatchPeripheral = MTWatchPeripheral()
    var fileAppModel: SJFileAppModel!
    let disposeBag = DisposeBag()
}
```

### 第二步：初始化

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    // 设置日志代理
    MTLog.delegate = self
    MTLog.enableConsolePrint = false

    // 设置数据发送代理
    mtWatchPeripheral.delegate = self

    // 创建文件传输管理器
    fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)

    // 注册蓝牙数据接收（⚠️ 替换为您自己的方式，见「替换蓝牙实现」章节）
    yourBLEManager.onDataReceived = { [weak self] data in
        guard let model = TLOCPModel(data: data) else { return }
        self?.mtWatchPeripheral.fff2Data.accept(model)
    }
}
```

### 第三步：实现两个必须的代理方法

```swift
// SDK 需要发送数据给设备时回调（⚠️ 替换为您自己的蓝牙写入方法）
func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
    yourBLEManager.sendData(data)
}

// SDK 内部日志回调
func mtLog(level: MTLogLevel, message: String, file: String, line: Int) {
    let fileName = (file as NSString).lastPathComponent
    print("[\(fileName):\(line)] \(message)")
}
```

### 第四步：清理资源

```swift
deinit {
    MTLog.delegate = nil
    MTLog.enableConsolePrint = true
    UIApplication.shared.isIdleTimerDisabled = false
}
```

---

## 替换蓝牙实现

OTA SDK 通过两个点与外部蓝牙管理器交互，集成时只需替换这两处：

### 1. 数据接收（设备 → App → SDK）

从蓝牙接收到原始数据后，解析为 `TLOCPModel` 并传给 SDK：

```swift
// ⚠️ 示例中是：WMOtherDataDelegate.devicePushRawData(_:)
// 替换为您自己的蓝牙接收回调，核心一行不变：
guard let model = TLOCPModel(data: data) else { return }
mtWatchPeripheral.fff2Data.accept(model)
```

**不同蓝牙框架对应写法：**

```swift
// CoreBluetooth
func peripheral(_ peripheral: CBPeripheral,
                didUpdateValueFor characteristic: CBCharacteristic,
                error: Error?) {
    guard let data = characteristic.value,
          let model = TLOCPModel(data: data) else { return }
    mtWatchPeripheral.fff2Data.accept(model)
}

// 第三方 SDK 回调风格
yourBLEManager.onDataReceived = { [weak self] data in
    guard let model = TLOCPModel(data: data) else { return }
    self?.mtWatchPeripheral.fff2Data.accept(model)
}

// RxBluetooth
yourRxBluetooth.dataObservable
    .compactMap { TLOCPModel(data: $0) }
    .subscribe(onNext: { [weak self] model in
        self?.mtWatchPeripheral.fff2Data.accept(model)
    })
    .disposed(by: disposeBag)
```

### 2. 数据发送（SDK → App → 设备）

在 `watchPeripheral(_:needSendData:)` 中调用您的蓝牙写入接口：

```swift
// ⚠️ 示例中是：WatchManager.sharedInstance().currentValue.sendIfNeed(data)
// 替换为您自己的蓝牙发送方法：

func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
    // CoreBluetooth
    cbPeripheral.writeValue(data, for: fff1Characteristic, type: .withoutResponse)

    // 或第三方 SDK
    // yourBLEManager.sendData(data)
}
```

---

## 启动 OTA 升级

### 支持的文件格式

| 扩展名 | 说明 |
|--------|------|
| `.up` | 标准 OTA 固件包 |
| `.upex` | 扩展固件包（tar 格式，含多个文件） |

### 开始传输

```swift
func startOTA(fileURL: URL) {
    UIApplication.shared.isIdleTimerDisabled = true  // 防止锁屏

    fileAppModel.startTransferFile(fileURL)
        .observe(on: MainScheduler.instance)
        .subscribe(
            onNext: { [weak self] progress in
                // 注意：失败状态也会从 onNext 推送，需要检查 isFail
                guard !progress.isFail else {
                    self?.handleError(progress.error)
                    UIApplication.shared.isIdleTimerDisabled = false
                    return
                }
                // progress.progress 范围是 0–100
                self?.progressView.progress = Float(progress.progress / 100)
            },
            onError: { [weak self] error in
                self?.handleError(error)
                UIApplication.shared.isIdleTimerDisabled = false
            },
            onCompleted: {
                print("OTA 升级成功")
                UIApplication.shared.isIdleTimerDisabled = false
            }
        )
        .disposed(by: disposeBag)
}
```

### 取消传输

```swift
fileAppModel.cancelTransfer()
UIApplication.shared.isIdleTimerDisabled = false
// 手动恢复 UI 状态（SDK 不会触发 onCompleted）
```

### 处理错误

```swift
func handleError(_ error: Error?) {
    guard let error = error else { return }
    let msg: String
    if let e = error as? SJFileTransferError {
        msg = e.errorDescription ?? "未知错误"
    } else {
        msg = error.localizedDescription
    }
    print("OTA 失败：\(msg)")
}
```

**`SJFileTransferError` 枚举值：**

| case | 含义 |
|------|------|
| `.busy` | 设备正忙 |
| `.lowBattery` | 电量不足 |
| `.lowStorage` / `.notEnoughSpace` | 存储空间不足 |
| `.fileError` | 文件格式不支持或无法读取 |
| `.fileDamaged` | `.upex` 文件损坏 |
| `.disconnect` | 蓝牙连接断开 |
| `.equipmentFailure` | 设备故障 |
| `.dialMax` | 表盘数量已达上限 |
| `.unknown` / `.other(String)` | 其他错误 |

---

## API 速查

| 类 / 协议 | 关键成员 | 说明 |
|-----------|---------|------|
| `SJFileAppModel` | `init(peripheral:)` | 初始化，传入 `MTWatchPeripheral` |
| | `startTransferFile(_ url:) -> Observable<SJFileProgress>` | 开始 OTA，返回进度流 |
| | `cancelTransfer()` | 取消传输 |
| `MTWatchPeripheral` | `delegate` | 设置数据发送代理 |
| | `fff2Data: PublishRelay<TLOCPModel>` | 接收设备数据的入口，调用 `accept` |
| `MTWatchPeripheralDelegate` | `watchPeripheral(_:needSendData:)` | SDK 需要发送数据时回调，**必须实现** |
| `MTLog` | `delegate` | 设置日志代理 |
| | `enableConsolePrint` | 是否同时打印到控制台 |
| `MTLogDelegate` | `mtLog(level:message:file:line:)` | 接收 SDK 日志，**必须实现** |
| `SJFileProgress` | `progress: Double` | 当前进度（**0–100**，非 0–1） |
| | `isFail: Bool` | 是否失败（需在 onNext 中检查） |
| | `error: Error?` | 失败原因 |
| `TLOCPModel` | `init?(data:)` | 解析原始蓝牙数据，失败返回 nil |

---

## 注意事项

- **防止锁屏**：升级期间设置 `isIdleTimerDisabled = true`，结束后恢复
- **文件沙盒权限**：通过系统文件选择器获取的 URL，需调用 `startAccessingSecurityScopedResource()`，传输结束后调用 `stopAccessingSecurityScopedResource()`
- **进度值**：`SJFileProgress.progress` 是 0–100，赋值给 `UIProgressView` 时需要 `/ 100`
- **双失败路径**：`onNext`（`isFail == true`）和 `onError` 都可能携带失败状态，两者都要处理
- **取消后手动更新 UI**：`cancelTransfer()` 不会触发 `onCompleted`，需自行恢复按钮状态
- **代理置 nil**：`deinit` 中将 `MTLog.delegate = nil`，避免野指针
