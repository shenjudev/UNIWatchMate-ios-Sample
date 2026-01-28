# 📝 UNIOTAUsageExample.swift 说明

## 文件特点

✅ **完全独立** - 不依赖任何外部SDK  
✅ **仅用系统库** - 只引用 Foundation 和 UIKit  
✅ **详细注释** - 所有关键点都有TODO和提示  
✅ **代码模板** - 可以直接复制使用  

---

## 依赖说明

### 系统库（已引用）
```swift
import Foundation  // 系统基础库
import UIKit       // iOS UI框架
```

### OTA SDK类（需要同时引入）
这个示例文件使用了以下OTA SDK提供的类型：
- `UNIOTAManager` - OTA管理器
- `UNIOTAManagerDelegate` - OTA协议
- `UNIOTALogLevel` - 日志级别枚举
- `UNIOTAProgress` - 进度信息结构体
- `UNIOTAResult` - 结果枚举
- `UNIOTAError` - 错误类型枚举

这些类型定义在以下文件中：
- `UNIOTAModels.swift`
- `UNIOTAManagerDelegate.swift`
- `UNIOTAManager.swift`

### ⚠️ 不依赖任何外部SDK

这个示例文件**不依赖**以下库：
- ❌ RxSwift
- ❌ RxCocoa
- ❌ PromiseKit
- ❌ CoreBluetooth（在示例中只有注释，没有实际引用）
- ❌ 任何第三方蓝牙库

---

## 使用方法

### 方式1：直接在项目中使用

1. 确保已添加OTA SDK核心文件：
   - `UNIOTAModels.swift`
   - `UNIOTAManagerDelegate.swift`
   - `UNIOTAManager.swift`

2. 将 `UNIOTAUsageExample.swift` 添加到项目

3. 修改关键部分：
   - 替换 `MyBluetoothManager` 为你的蓝牙管理器
   - 实现 `sendData` 方法中的实际蓝牙发送逻辑
   - 在蓝牙接收回调中调用 `didReceiveData`

### 方式2：作为参考模板

1. 复制需要的部分到你的现有ViewController
2. 参考注释实现对应功能
3. 根据实际需求调整UI

---

## 关键实现点

### 1. 初始化OTA管理器

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // 创建OTA管理器
    otaManager = UNIOTAManager()
    otaManager.delegate = self
}
```

### 2. 实现发送蓝牙数据（⭐️ 核心）

```swift
func otaManager(_ manager: UNIOTAManager,
               sendData data: Data,
               completion: @escaping (Bool) -> Void) {
    
    // TODO: 使用你的蓝牙管理器发送数据
    yourBLEManager.write(data) { error in
        completion(error == nil)
    }
}
```

### 3. 接收蓝牙数据（⭐️ 核心）

```swift
// 在你的蓝牙数据接收回调中
func peripheral(_ peripheral: CBPeripheral,
                didUpdateValueFor characteristic: CBCharacteristic,
                error: Error?) {
    guard let data = characteristic.value else { return }
    
    // 传递给OTA管理器
    otaManager.receiveData(from: data)
}
```

### 4. 实现进度更新

```swift
func otaManager(_ manager: UNIOTAManager,
               didUpdateProgress progress: UNIOTAProgress) {
    // 更新UI
    progressView.progress = Float(progress.progress / 100.0)
}
```

### 5. 处理完成结果

```swift
func otaManager(_ manager: UNIOTAManager,
               didFinishWith result: UNIOTAResult) {
    switch result {
    case .success:
        print("升级成功")
    case .failure(let error):
        print("失败: \(error)")
    case .cancelled:
        print("已取消")
    }
}
```

---

## MyBluetoothManager 说明

### 这是什么？

`MyBluetoothManager` 是一个**模拟的蓝牙管理器类**，仅供示例参考。

### 它不是什么？

- ❌ 不是真正的蓝牙实现
- ❌ 不依赖CoreBluetooth
- ❌ 不依赖任何第三方库
- ❌ 不能直接使用

### 如何替换？

你需要根据自己的蓝牙实现方式替换它：

#### 选项1：使用 CoreBluetooth

```swift
import CoreBluetooth

class YourBLEManager: NSObject, CBPeripheralDelegate {
    var peripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    var onDataReceived: ((Data) -> Void)?
    
    func sendData(_ data: Data, completion: @escaping (Error?) -> Void) {
        guard let peripheral = peripheral,
              let characteristic = writeCharacteristic else {
            completion(NSError(domain: "BLE", code: -1))
            return
        }
        
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
        // 保存completion，在didWriteValueFor中调用
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value else { return }
        onDataReceived?(data)
    }
}
```

#### 选项2：使用你们公司的蓝牙SDK

```swift
class YourBLEManager {
    var onDataReceived: ((Data) -> Void)?
    
    func sendData(_ data: Data, completion: @escaping (Error?) -> Void) {
        // 使用你们的SDK
        YourCompanyBLESDK.shared.write(data) { success, error in
            completion(error)
        }
    }
    
    init() {
        // 设置接收回调
        YourCompanyBLESDK.shared.onReceive = { [weak self] data in
            self?.onDataReceived?(data)
        }
    }
}
```

---

## TODO 清单

示例代码中标记了以下需要实现的部分：

- [ ] **替换蓝牙管理器**
  ```swift
  // 第18行
  var myBluetoothManager: MyBluetoothManager!
  ```

- [ ] **实现蓝牙数据发送**
  ```swift
  // 第293行，sendData 方法
  func sendData(_ data: Data, completion: @escaping (Error?) -> Void)
  ```

- [ ] **实现蓝牙数据接收**
  ```swift
  // 第337行，didReceiveData 方法
  func didReceiveData(_ data: Data)
  ```

- [ ] **（可选）调整UI布局**
  ```swift
  // 第77-94行，setupUI 方法
  ```

---

## 编译说明

### 当前状态

这个文件**可以编译**，因为：
- 只引用系统库（Foundation, UIKit）
- OTA SDK的类型都是自定义的（在同一个项目中）
- `MyBluetoothManager` 是本文件中定义的

### 运行要求

要实际运行OTA功能，需要：
1. ✅ 添加OTA SDK核心文件（3个）
2. ✅ 实现真实的蓝牙发送/接收逻辑
3. ✅ 有可用的蓝牙设备连接

---

## 总结

这个示例文件是一个**纯净的代码模板**，特点是：

✅ 不依赖任何外部SDK  
✅ 只使用系统库  
✅ 提供详细的TODO注释  
✅ 包含完整的实现示例  
✅ 可以直接复制使用  

你只需要：
1. 替换蓝牙管理器实现
2. 填写TODO部分的代码
3. 根据需要调整UI

就可以快速集成OTA功能到你的项目中！🎉
