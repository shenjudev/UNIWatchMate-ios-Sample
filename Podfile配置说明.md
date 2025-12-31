# Podfile 配置详细说明

## 一、基础配置部分

### 1. 依赖库源地址（已注释）
```ruby
#source 'https://github.com/CocoaPods/Specs.git'
```
- **作用**：指定 CocoaPods 的官方仓库地址
- **说明**：这行被注释掉了，表示使用默认的 CocoaPods 源

### 2. 平台版本设置
```ruby
platform :ios, '13.0'
```
- **作用**：指定 iOS 项目的最低支持版本为 iOS 13.0
- **说明**：所有依赖库都必须兼容 iOS 13.0 及以上版本

### 3. Flutter 集成配置
```ruby
flutter_application_path = '../sound_buds'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
```
- **作用**：配置 Flutter 应用的路径，并加载 Flutter 的 Pod 辅助脚本
- **说明**：用于在 iOS 项目中集成 Flutter 模块

### 4. 工作空间配置
```ruby
workspace 'LensMoo.xcworkspace'
```
- **作用**：指定生成的 Xcode 工作空间文件名
- **说明**：CocoaPods 会创建一个 `.xcworkspace` 文件，用于管理多个项目

### 5. 框架使用方式
```ruby
use_frameworks!
```
- **作用**：强制所有 Pod 以动态框架（Framework）形式集成，而不是静态库
- **说明**：动态框架可以加快编译速度，但会增加应用体积

---

## 二、各个 Target 配置

### Target 1: CameraCapture
```ruby
target 'CameraCapture' do
  project '../SJWatchLib/CameraCapture/CameraCapture.xcodeproj'
end
```
- **作用**：配置相机捕获模块的 Target
- **说明**：这是一个独立的子项目，目前没有添加任何 Pod 依赖

### Target 2: SJWatchTheme
```ruby
target 'SJWatchTheme' do
  project '../SJWatchTheme/SJWatchTheme.xcodeproj'
end
```
- **作用**：配置手表主题模块的 Target
- **说明**：主题相关的子项目，目前没有 Pod 依赖

### Target 3: TLOCP
```ruby
target 'TLOCP' do
  project '../SJWatchLib/TLOCP/TLOCP.xcodeproj'
end
```
- **作用**：配置 TLOCP 模块的 Target
- **说明**：另一个子项目，目前没有 Pod 依赖

### Target 4: UNIWatchMate
```ruby
target 'UNIWatchMate' do
  project '../UNIWatchMate/UNIWatchMate.xcodeproj'
  pod 'ReactiveObjC'
end
```
- **作用**：配置 UNIWatchMate SDK 的 Target
- **依赖库**：
  - `ReactiveObjC`：响应式编程框架（Objective-C 版本）

### Target 5: SJWatchLib
```ruby
target 'SJWatchLib' do
  project '../SJWatchLib/SJWatchLib.xcodeproj'
  pod "ReactiveObjC"
  pod 'RxSwift', '6.8.0'
  pod 'RxCocoa', '6.8.0'
  pod 'PromiseKit'
  pod 'SwiftyJSON', '~> 5.0.1'
  pod 'SWCompression/TAR'
end
```
- **作用**：配置手表库的 Target
- **依赖库说明**：
  - `ReactiveObjC`：响应式编程框架
  - `RxSwift`：响应式编程框架（Swift 版本），固定版本 6.8.0
  - `RxCocoa`：RxSwift 的 Cocoa 扩展，固定版本 6.8.0
  - `PromiseKit`：Promise 异步编程库
  - `SwiftyJSON`：JSON 解析库，版本要求 >= 5.0.1 且 < 6.0.0（~> 表示兼容版本）
  - `SWCompression/TAR`：TAR 压缩解压库的子模块

### Target 6: LensMoo（主应用）
这是最复杂的主应用 Target，包含大量依赖库：

#### 6.1 UI 布局相关
```ruby
pod 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit.git'
```
- **作用**：自动布局库，使用 Git 仓库直接安装

#### 6.2 响应式编程
```ruby
pod "ReactiveObjC"
pod 'RxSwift', '6.8.0'
pod 'RxCocoa', '6.8.0'
pod 'PromiseKit'
```
- **作用**：提供响应式编程和 Promise 异步处理能力

#### 6.3 数据解析
```ruby
pod 'HandyJSON', '5.0.0'
pod 'SwiftyJSON', '~> 5.0.1'
pod 'ObjectMapper', '~> 4.2.0'
pod 'MJExtension', '~> 3.4.0'
```
- **作用**：多种 JSON 和对象映射库，用于数据模型转换

#### 6.4 照片选择
```ruby
pod 'HXPhotoPicker/Picker/Lite'
```
- **作用**：轻量级照片选择器

#### 6.5 本地库（使用路径引用）
```ruby
pod 'ReactorKit', :path=> './LocalLib/ReactorKit'
pod 'ProgressHUD', :path=> './LocalLib/ProgressHUD'
pod 'SJBase', :path=> './LocalLib/SJBase'
pod 'SJExtension', :path=> './LocalLib/SJExtension'
pod 'Regex', :path=> './LocalLib/Regex'
pod 'VisualEffectView', :path=> './LocalLib/VisualEffectView'
pod 'SKPhotoBrowser', :path=> './LocalLib/SKPhotoBrowser'
```
- **作用**：使用本地路径引用自定义库
- **说明**：`:path=>` 表示从本地文件系统路径加载 Pod

#### 6.6 UI 组件
```ruby
pod 'Toast-Swift'
pod 'TYPagerController'
pod 'FittedSheets'
pod 'KFGradientProgressView'
pod 'PPBadgeViewSwift'
pod 'YBPopupMenu'
pod 'RESegmentedControl', '~> 0.5.1'
pod 'JXBanner', '~> 0.3.6'
pod 'FSCalendar', '~> 2.8.2'
```
- **作用**：各种 UI 组件库（Toast 提示、分页控制器、弹窗、进度条、徽章、菜单、分段控件、轮播图、日历等）

#### 6.7 网络请求
```ruby
pod 'Moya/RxSwift'
pod 'Alamofire', '~> 5.10'
pod 'AFNetworking', '~> 4.0'
```
- **作用**：网络请求库（Moya 是基于 Alamofire 的封装）

#### 6.8 数据库
```ruby
pod 'WCDB', :git => 'https://github.com/Tencent/wcdb.git', :tag => 'v2.1.15'
pod 'WCDB.swift', :git => 'https://github.com/Tencent/wcdb.git', :tag => 'v2.1.15'
```
- **作用**：腾讯的数据库框架，使用 Git 仓库的特定版本（v2.1.15）

#### 6.9 图片加载
```ruby
pod 'Kingfisher'
pod 'KingfisherWebP'
pod 'SDWebImage', '~> 5.18'
pod 'FLAnimatedImage', '~> 1.0'
```
- **作用**：图片加载和缓存库（支持 WebP 格式和 GIF 动图）

#### 6.10 工具库
```ruby
pod 'SwifterSwift', '5.2.0'
pod 'Localize-Swift', '~> 3.2.0'
pod 'MMKV', '1.2.11'
pod 'KeychainAccess', '~> 4.2.2'
pod 'DeviceKit', '5.1.0'
pod 'PhoneNumberKit', "3.7.11"
```
- **作用**：Swift 扩展、本地化、键值存储、钥匙串访问、设备信息、电话号码解析等工具

#### 6.11 其他功能库
```ruby
pod 'CryptoSwift', '~> 1.4.2'      # 加密库
pod 'MJRefresh', '~> 3.7.0'        # 下拉刷新
pod 'IQKeyboardManagerSwift', '6.5.16'  # 键盘管理
pod 'R.swift', '~> 6.0.0-alpha.3'  # 资源管理
pod 'Bugly', '~> 2.6.1'            # 崩溃统计
pod 'Adhan', '~> 1.4.0'            # 穆斯林礼拜工具
pod 'Starscream', '~> 4.0.0'       # WebSocket
pod 'SocketRocket'                 # WebSocket（另一个库）
pod 'OpenSSL-Universal'            # SSL/TLS 加密库
pod 'onnxruntime-objc', '~> 1.16.1' # ONNX 运行时（AI 模型）
pod 'SSZipArchive'                 # ZIP 压缩
pod 'Zip', '~> 2.1.2'              # ZIP 压缩（另一个库）
pod 'Digger', :git => 'https://github.com/mazz/Digger.git'  # 文件下载
pod 'AWSS3'                        # AWS S3 云存储
pod 'YYText'                       # 富文本显示
pod 'AttributedLib'                # 属性字符串库
```

#### 6.12 Flutter 集成
```ruby
install_all_flutter_pods(flutter_application_path)
```
- **作用**：安装所有 Flutter 相关的 Pod

### Target 7: TSCommonLib
```ruby
target 'TSCommonLib' do
  pod 'SwifterSwift', '5.2.0'
  pod 'Localize-Swift', '~> 3.2.0'
  pod 'MMKV', '1.2.11'
  project '../TSCommonLib/TSCommonLib.xcodeproj'
end
```
- **作用**：通用库 Target，包含基础工具库

### Target 8: TSDBManagerLib
```ruby
target 'TSDBManagerLib' do
  pod 'MJExtension', '~> 3.4.0'
  pod 'WCDB', :git => 'https://github.com/Tencent/wcdb.git', :tag => 'v2.1.15'
  pod 'SwifterSwift', '5.2.0'
  pod 'Localize-Swift', '~> 3.2.0'
  pod 'MMKV', '1.2.11'
  project '../TSDBManagerLib/TSDBManagerLib.xcodeproj'
end
```
- **作用**：数据库管理库 Target，包含数据库和基础工具库

---

## 三、Pre-Install 钩子

```ruby
pre_install do |installer|
  remove_swiftui()
end

def remove_swiftui
  # 解决 xcode13 Release模式下SwiftUI报错问题
  system("rm -rf ./Pods/Kingfisher/Sources/SwiftUI")
  # ... 修改代码文件
end
```
- **作用**：在安装 Pod 之前执行，移除 Kingfisher 库中的 SwiftUI 相关代码
- **原因**：解决 Xcode 13 在 Release 模式下 SwiftUI 报错的问题

---

## 四、Post-Install 钩子

Post-Install 钩子在所有 Pod 安装完成后执行，用于修复各种编译问题。

### 1. WCDB 头文件路径修复
```ruby
# 为 WCDB 和 WCDB.swift 添加头文件搜索路径
if target.name == 'WCDB' || target.name == 'WCDB.swift'
  # 添加递归查找的所有头文件目录
  # 设置编译选项
end
```
- **作用**：修复 WCDB 数据库库的头文件找不到的问题
- **方法**：递归查找所有头文件目录并添加到搜索路径

### 2. Opus 模块映射修复
```ruby
# 修复 opus-ios.framework 的 module.modulemap 文件
opus_modulemaps.each do |opus_modulemap|
  # 将模块名从 opus-ios 改为 opus_ios（用下划线替代连字符）
end
```
- **作用**：修复 opus-ios 框架的模块映射文件
- **原因**：Xcode 26 和新版 Swift 不支持模块名中的连字符

### 3. 工具链目录修复
```ruby
# 修复 DT_TOOLCHAIN_DIR 为 TOOLCHAIN_DIR
IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
```
- **作用**：修复旧版本 Xcode 的工具链目录引用问题

### 4. 统一部署目标版本
```ruby
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
```
- **作用**：统一所有 Pod 的最低 iOS 版本为 13.0

### 5. 构建分发设置
```ruby
config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
```
- **作用**：启用库的分发构建模式，提高兼容性

### 6. Flutter 后处理
```ruby
flutter_post_install(installer) if defined?(flutter_post_install)
```
- **作用**：执行 Flutter 的安装后处理脚本

### 7. Flutter 权限配置
```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  'PERMISSION_MICROPHONE=1',  # 启用麦克风权限
  'PERMISSION_CAMERA=0',      # 禁用相机权限
  # ... 其他权限设置
]
```
- **作用**：配置 Flutter 权限处理器的权限开关
- **说明**：
  - `= 1` 表示启用该权限
  - `= 0` 表示禁用该权限
  - 这里只启用了麦克风权限，其他权限都禁用了

---

## 五、版本号说明

### 版本号格式：
1. **固定版本**：`'6.8.0'` - 使用确切的版本号
2. **兼容版本**：`'~> 5.0.1'` - 允许 >= 5.0.1 且 < 6.0.0 的版本
3. **Git 仓库**：`:git => 'url'` - 从 Git 仓库安装
4. **本地路径**：`:path=> './path'` - 从本地路径安装
5. **Git 标签**：`:tag => 'v2.1.15'` - 使用 Git 仓库的特定标签

---

## 六、总结

这个 Podfile 配置了一个复杂的多模块 iOS 项目，包含：
- **8 个不同的 Target**（子项目）
- **100+ 个依赖库**
- **Flutter 集成**
- **多个编译问题修复脚本**

主要特点：
1. 使用动态框架（`use_frameworks!`）
2. 最低支持 iOS 13.0
3. 大量使用响应式编程库（RxSwift、ReactiveObjC）
4. 集成了 Flutter 模块
5. 包含多个编译问题修复脚本

