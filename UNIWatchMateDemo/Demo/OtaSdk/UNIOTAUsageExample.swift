//
//  UNIOTAUsageExample.swift
//  UNIWatchMateDemo
//
//  Created by OTA SDK on 2026/01/23.
//  OTA SDK Demo - 使用 SJFileAppModel 进行 OTA 升级
//
//  ✅ 使用 SJFileAppModel 封装 OTA 逻辑
//  ✅ 支持 .up 和 .upex 格式固件文件
//  ✅ 纯 Swift 实现，使用 RxSwift
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// MARK: - OTA SDK Demo

/// OTA SDK 演示界面
/// 展示如何使用 SJFileAppModel 进行固件升级
/// 
/// 功能：
/// 1. 选择 .up 或 .upex 固件文件
/// 2. 自动进行文件校验和CRC计算
/// 3. 实时显示升级进度和日志
/// 4. 支持取消升级操作
@objc public class OTAExampleViewController: UIViewController, WMOtherDataDelegate, MTWatchPeripheralDelegate, MTLogDelegate {
   
    
    
    // MARK: - WMOtherDataDelegate（接收真实蓝牙数据）
    
    public func device4A02Push(_ data: Data) {
        
    }
    
    public func deviceAudioRecord(_ data: Data) {
        
    }
    
    /// 接收原始蓝牙数据（从真实设备）
    /// - Parameter data: 原始数据
    /// - Note: 这个方法接收从 WatchManager 来的真实蓝牙数据
    public func devicePushRawData(_ data: Data) {
        // 解析 TLOCP 模型
        guard let model = TLOCPModel(data: data) else {
            appendLog("⚠️ 数据解析失败")
            return
        }
        
        // 将解析后的模型传递给 MTWatchPeripheral
        mtWatchPeripheral.fff2Data.accept(model)
        
        // 打印日志（可选）
        DDLogInfo("📥 收到设备数据: sceneId=0x\(String(format: "%02X", model.sceneId)), commandId=0x\(String(format: "%04X", model.commandId)) payload = \(model.payload.toHexString())")
    }
    
    // MARK: - MTWatchPeripheralDelegate（发送数据到真实设备）
    
//    /// MTWatchPeripheral 需要发送数据时的回调
//    /// - Parameters:
//    ///   - peripheral: MTWatchPeripheral 实例
//    ///   - data: 需要发送的数据
//    /// - Note: 这个方法将数据通过 WatchManager 发送到真实设备
     func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
        // 使用 WatchManager 发送数据到真实设备
        WatchManager.sharedInstance().currentValue.sendIfNeed(data)
        
        // 打印日志（可选）
        if let model = TLOCPModel(data: data) {
            DDLogInfo("📤 发送数据: sceneId=0x\(String(format: "%02X", model.sceneId)), commandId=0x\(String(format: "%04X", model.commandId)), size=\(data.count) bytes")
        } else {
            DDLogInfo("📤 发送数据: size=\(data.count) bytes")
        }
    }
    
    // MARK: - MTLogDelegate（接收 OTA SDK 的日志回调）
    
    /// 接收来自 OTA SDK 内部的日志
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    ///   - file: 文件名
    ///   - line: 行号
    func mtLog(level: MTLogLevel, message: String, file: String, line: Int) {
        // 根据日志级别添加不同的图标
        let icon: String
        switch level {
        case .debug:
            icon = "🔍"
        case .info:
            icon = "ℹ️"
        case .error:
            icon = "❌"
        }
        
        // 提取文件名（不包含路径）
        let fileName = (file as NSString).lastPathComponent
        
        // 格式化日志消息
        let logMessage = "\(icon) [\(fileName):\(line)] \(message)"
        
        // 添加到日志视图
        appendLog(logMessage)
    }
    
    // MARK: - Properties
    
    /// 文件传输管理器（使用 SJFileAppModel）
    private var fileAppModel: SJFileAppModel!
    
    /// RxSwift DisposeBag（管理订阅）
    private let disposeBag = DisposeBag()
    
    /// 当前文件 URL（用于停止访问权限）
    private var currentFileURL: URL?
    
    let mtWatchPeripheral =  MTWatchPeripheral()

    // MARK: - UI Controls
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始OTA升级", for: .normal)
        button.addTarget(self, action: #selector(startOTAButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消升级", for: .normal)
        button.addTarget(self, action: #selector(cancelOTAButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0
        return progressView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "等待开始..."
        return label
    }()
    
    private lazy var logTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        return textView
    }()
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupFileAppModel()
    }
    
    deinit {
        // 清理 MTLog 代理
        MTLog.delegate = nil
        MTLog.enableConsolePrint = true  // 恢复控制台打印
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "OTA升级"
        
        // 布局UI控件
        view.addSubview(startButton)
        view.addSubview(cancelButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)
        view.addSubview(logTextView)
        
        // 简单的frame布局
        startButton.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 44)
        cancelButton.frame = CGRect(x: 20, y: 154, width: view.bounds.width - 40, height: 44)
        progressView.frame = CGRect(x: 20, y: 220, width: view.bounds.width - 40, height: 4)
        statusLabel.frame = CGRect(x: 20, y: 240, width: view.bounds.width - 40, height: 60)
        logTextView.frame = CGRect(x: 20, y: 320, width: view.bounds.width - 40, height: 300)
    }
    
    private func setupFileAppModel() {
        // ✅ 设置 MTLog 的代理为当前 ViewController
        // 这样 OTA SDK 内部的所有日志都会回调到这里
        MTLog.delegate = self
        MTLog.enableConsolePrint = false  // 禁用控制台打印，只通过代理回调
        
        // 设置 MTWatchPeripheral 的代理为当前 ViewController
        // 这样当 MTWatchPeripheral 需要发送数据时，会回调到 watchPeripheral(_:needSendData:)
        mtWatchPeripheral.delegate = self
        
        // 初始化文件传输管理器
        self.fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)
        self.appendLog("✅ 文件传输管理器初始化成功")
        
        // 设置 WatchManager 的数据接收代理
        // 当真实设备发送数据时，会回调到 devicePushRawData(_:)
        
        WatchManager.sharedInstance().current.subscribeNext { [weak self] peripheral in
            peripheral?.otherDataDelegate = self
        }
    }
    
    // MARK: - Actions
    
    @objc private func startOTAButtonTapped() {
        // 检查设备是否连接
        guard fileAppModel != nil else {
            showAlert(message: "设备未连接，请先连接设备")
            return
        }
        
        // 选择OTA文件
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: ["public.item"],
            in: .open
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
    
    @objc private func cancelOTAButtonTapped() {
        // 取消文件传输
        fileAppModel?.cancelTransfer()
        appendLog("🛑 用户取消OTA升级")
        
        // 恢复UI状态
        DispatchQueue.main.async {
            self.startButton.isEnabled = true
            self.cancelButton.isEnabled = false
            self.statusLabel.text = "已取消"
        }
        
        // 停止访问文件
        currentFileURL?.stopAccessingSecurityScopedResource()
        currentFileURL = nil
    }
    
    // MARK: - OTA Transfer
    
    /// 开始OTA文件传输
    /// - Parameter fileURL: 固件文件URL
    private func startOTATransfer(with fileURL: URL) {
        // 保存文件URL（用于后续停止访问）
        currentFileURL = fileURL
        
        appendLog("📁 开始OTA升级: \(fileURL.lastPathComponent)")
        
        // 更新UI状态
        DispatchQueue.main.async {
            self.startButton.isEnabled = false
            self.cancelButton.isEnabled = true
            self.progressView.progress = 0
            self.statusLabel.text = "准备中..."
        }
        UIApplication.shared.isIdleTimerDisabled = true
        // 使用 SJFileAppModel 开始文件传输
        fileAppModel.startTransferFile(fileURL)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] progress in
                    // 处理进度更新
                    guard progress.isFail == false else {
                        self?.handleTransferError(progress.error ?? .mt(.other))
                        self?.currentFileURL?.stopAccessingSecurityScopedResource()
                        self?.currentFileURL = nil
                        UIApplication.shared.isIdleTimerDisabled = false
                        return
                    }
                    self?.handleProgress(progress)
                },
                onError: { [weak self] error in
                    // 处理错误
                    self?.handleTransferError(error)
                    self?.currentFileURL?.stopAccessingSecurityScopedResource()
                    self?.currentFileURL = nil
                    UIApplication.shared.isIdleTimerDisabled = false
                },
                onCompleted: { [weak self] in
                    // 传输完成
                    self?.handleTransferCompleted()
                    self?.currentFileURL?.stopAccessingSecurityScopedResource()
                    self?.currentFileURL = nil
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            )
            .disposed(by: disposeBag)
    }
    var currentIntProgress = 0

    /// 处理进度更新
    /// - Parameter progress: 进度信息
    private func handleProgress(_ progress: SJFileProgress) {
        DispatchQueue.main.async {
            // 更新进度条
            self.progressView.progress = Float(progress.progress/100)
            
            // 更新状态标签
            let percentage = progress.progress
            let statusText = """
            传输中...
            进度: \(String(format: "%.1f", percentage))%
            文件: \(progress.currentIndex) / \(progress.totalCount)
            """
            self.statusLabel.text = statusText
            // 记录日志
            if progress.progress > 0 && progress.progress < 100 {

                if self.currentIntProgress != Int(percentage) {  // 每10%记录一次
                    self.appendLog("📊 传输进度: \(String(format: "%.1f", percentage))%")
                    self.currentIntProgress = Int(percentage)
                }
            }
        }
    }
    
    /// 处理传输错误
    /// - Parameter error: 错误信息
    private func handleTransferError(_ error: Error) {
        DispatchQueue.main.async {
            // 恢复UI状态
            self.startButton.isEnabled = true
            self.cancelButton.isEnabled = false
            self.statusLabel.text = "升级失败"
            
            // 显示错误信息
            let errorMessage: String
            if let fileError = error as? SJFileTransferError {
                errorMessage = fileError.errorDescription ?? "未知错误"
                self.appendLog("❌ OTA升级失败: \(errorMessage)")
            } else {
                errorMessage = error.localizedDescription
                self.appendLog("❌ OTA升级失败: \(errorMessage)")
            }
            
            self.showAlert(message: "升级失败: \(errorMessage)")
        }
    }
    
    /// 处理传输完成
    private func handleTransferCompleted() {
        DispatchQueue.main.async {
            // 恢复UI状态
            self.startButton.isEnabled = true
            self.cancelButton.isEnabled = false
            self.progressView.progress = 1.0
            self.statusLabel.text = "升级成功"
            
            // 显示成功提示
            self.appendLog("🎉 OTA升级成功！")
            self.showAlert(message: "🎉 OTA升级成功！设备将自动重启")
        }
    }
    
    // MARK: - Helper Methods
    
    private func appendLog(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = DateFormatter.localizedString(
                from: Date(),
                dateStyle: .none,
                timeStyle: .medium
            )
            let logMessage = "[\(timestamp)] \(message)\n"
            self.logTextView.text += logMessage
            
            // 滚动到底部
            let bottom = NSMakeRange(self.logTextView.text.count - 1, 1)
            self.logTextView.scrollRangeToVisible(bottom)
            DDLogInfo(message)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension OTAExampleViewController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        
        // 检查文件扩展名
        let pathExtension = fileURL.pathExtension.lowercased()
        guard pathExtension == "up" || pathExtension == "upex" else {
            showAlert(message: "请选择.up或.upex格式的固件文件")
            return
        }
        
        // 访问文件权限（iOS安全沙盒要求）
        guard fileURL.startAccessingSecurityScopedResource() else {
            showAlert(message: "无法访问文件")
            return
        }
        
        // 显示确认弹窗
        showConfirmAlert(for: fileURL)
    }
    
    /// 显示 OTA 确认弹窗
    /// - Parameter fileURL: 选中的固件文件 URL
    private func showConfirmAlert(for fileURL: URL) {
        let fileName = fileURL.lastPathComponent
        let fileSize = getFileSize(fileURL)
        
        let message = """
        文件名: \(fileName)
        文件大小: \(fileSize)
        
        确定要开始 OTA 升级吗？
        升级过程中请保持设备连接。
        """
        
        let alert = UIAlertController(
            title: "确认升级",
            message: message,
            preferredStyle: .alert
        )
        
        // 取消按钮
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            // 用户取消，停止访问文件
            fileURL.stopAccessingSecurityScopedResource()
            self?.appendLog("ℹ️ 用户取消了 OTA 升级")
        })
        
        // 确定按钮
        alert.addAction(UIAlertAction(title: "开始升级", style: .default) { [weak self] _ in
            // 用户确认，开始 OTA 升级
            self?.startOTATransfer(with: fileURL)
        })
        
        present(alert, animated: true)
    }
    
    /// 获取文件大小（格式化为可读字符串）
    /// - Parameter url: 文件 URL
    /// - Returns: 格式化的文件大小字符串（例如："1.2 MB"）
    private func getFileSize(_ url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? UInt64 {
                return formatFileSize(fileSize)
            }
        } catch {
            MTLog.debug("获取文件大小失败: \(error)")
        }
        return "未知"
    }
    
    /// 格式化文件大小
    /// - Parameter bytes: 字节数
    /// - Returns: 格式化的字符串
    private func formatFileSize(_ bytes: UInt64) -> String {
        let kb = Double(bytes) / 1024.0
        let mb = kb / 1024.0
        
        if mb >= 1.0 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1.0 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(bytes) Bytes"
        }
    }
    
    /// 显示简单提示弹窗
    /// - Parameter message: 提示消息
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "提示",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - 集成说明

/*
 # OTA SDK Demo 使用说明
 
 ## ⚠️ 重要说明：外部依赖
 
 本示例使用了 **WatchManager** 和 **WMOtherDataDelegate** 作为蓝牙数据收发的示例实现。
 这些是**外部依赖**，仅用于演示目的。
 
 **集成到您的项目时，需要替换为您自己的蓝牙管理器实现。**
 
 ### 需要实现的功能
 
 1. **接收蓝牙数据**（替换 WMOtherDataDelegate）
    - 从您的蓝牙设备接收原始数据 `Data`
    - 解析为 `TLOCPModel`
    - 传递给 `mtWatchPeripheral.fff2Data.accept(model)`
 
 2. **发送蓝牙数据**（替换 WatchManager.sendIfNeed）
    - 通过 `MTWatchPeripheralDelegate.watchPeripheral(_:needSendData:)` 接收数据
    - 使用您的蓝牙管理器发送数据到设备
 
 3. Bridging-Header中需要引入以下项
 #import "OtaSdk/Lib/UNIOTACLFSR.h"
 #import "OtaSdk/Lib/UNIOTABtUtils.h"
 
 详细的替换指南请参考 **"集成到您的项目"** 章节。
 
 ---
 
 ## 功能特性
 ✅ 使用 SJFileAppModel 进行 OTA 文件传输
 ✅ 使用 MTWatchPeripheral 作为蓝牙外设代理
 ✅ 支持 .up 和 .upex 格式固件文件
 ✅ 自动进行文件校验和完整性检查（tar 完整性）
 ✅ 实时显示升级进度和日志（带文件名和行号）
 ✅ 支持升级确认弹窗（显示文件名和大小）
 ✅ 支持取消升级操作
 ✅ 自动处理 TLOCP 协议封装
 ✅ 升级期间自动禁用屏幕休眠
 ✅ 所有 OTA SDK 日志统一回调到 UI
 
 ## 使用流程
 1. 确保蓝牙设备已连接（使用您自己的蓝牙管理器）
 2. 点击"开始OTA升级"按钮
 3. 选择固件文件（.up 或 .upex）
 4. 确认弹窗显示文件信息，点击"开始升级"
 5. 等待升级完成（自动处理所有通信）
 
 ## 核心架构
 
 ### 1. 代理协议实现
 
 ```swift
 @objc public class OTAExampleViewController: UIViewController, 
                                               WMOtherDataDelegate,           // ⚠️ 示例：接收蓝牙数据（需替换）
                                               MTWatchPeripheralDelegate,     // ✅ OTA SDK：发送数据回调
                                               MTLogDelegate {                // ✅ OTA SDK：日志回调
     
     // ✅ OTA SDK 核心组件
     let mtWatchPeripheral = MTWatchPeripheral()       // 蓝牙外设代理
     private var fileAppModel: SJFileAppModel!          // 文件传输管理器
     private let disposeBag = DisposeBag()              // RxSwift 订阅管理
 }
 ```
 
 **说明**：
 - `MTWatchPeripheralDelegate`：OTA SDK 的代理，**必须实现**
 - `MTLogDelegate`：OTA SDK 的日志代理，**必须实现**
 - `WMOtherDataDelegate`：**仅为示例**，集成时替换为您自己的蓝牙数据接收方式
 

 ### 2. 初始化设置
 
 ```swift
 private func setupFileAppModel() {
     // ✅ 步骤 1: 设置 MTLog 代理（接收所有 OTA SDK 内部日志）
     MTLog.delegate = self
     MTLog.enableConsolePrint = false  // 只在 UI 显示，不打印到控制台
     
     // ✅ 步骤 2: 设置 MTWatchPeripheral 代理（数据发送回调）
     mtWatchPeripheral.delegate = self
     
     // ✅ 步骤 3: 创建文件传输管理器
     self.fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)
     self.appendLog("✅ 文件传输管理器初始化成功")
     
     // ⚠️ 步骤 4: 设置蓝牙数据接收（此处使用 WatchManager 作为示例，需替换）
     WatchManager.sharedInstance().current.subscribeNext { [weak self] peripheral in
         peripheral?.otherDataDelegate = self
     }
 }
 ```
 
 ### 3. 数据流向图
 
 ```
 ┌─────────────────────────────────────────────────────────────────┐
 │                      双向数据通信流程                            │
 └─────────────────────────────────────────────────────────────────┘
 
 【设备 → App 方向】（⚠️ 此部分需要替换为您的蓝牙管理器）
 真实蓝牙设备发送数据
     ↓
 ⚠️ 您的蓝牙管理器（替换 WatchManager）
     ↓
 ⚠️ 您的数据接收回调（替换 WMOtherDataDelegate.devicePushRawData）
     ├─ 解析：TLOCPModel(data: data)
     └─ ✅ 转发给 OTA SDK：mtWatchPeripheral.fff2Data.accept(model)
         ↓
 ✅ MTWatchPeripheral.fff2Data（PublishRelay<TLOCPModel>）
     ↓
 ✅ SJSendFileTask 监听并处理
     └─ sendResult(sceneId:commandId:) 过滤 OTA 相关数据
 
 【App → 设备方向】（⚠️ 此部分需要替换为您的蓝牙管理器）
 ✅ SJFileAppModel 需要发送数据
     ↓
 ✅ MTWatchPeripheral.sendIfNeed(data)
     ↓
 ✅ MTWatchPeripheral.otaManager(sendData:)
     ↓
 ✅ MTWatchPeripheralDelegate.watchPeripheral(_:needSendData:)
     ↓
 ⚠️ 您的 ViewController 实现（当前示例使用 WatchManager）
     └─ ⚠️ 使用您的蓝牙管理器发送（替换 WatchManager.sendIfNeed）
         ↓
 真实蓝牙设备接收数据
 
 【日志回调】（✅ OTA SDK 内部机制，无需修改）
 ✅ OTA SDK 内部任何文件调用 MTLog.debug/info/error()
     ↓
 ✅ MTLogDelegate.mtLog(level:message:file:line:)
     ↓
 您的 ViewController.mtLog()
     ├─ 添加图标（🔍/ℹ️/❌）
     ├─ 提取文件名和行号
     └─ appendLog() 显示在 UI
 ```
 
 ### 4. 文件选择和确认
 
 ```swift
 // 文件选择
 public func documentPicker(_ controller: UIDocumentPickerViewController, 
                           didPickDocumentsAt urls: [URL]) {
     guard let fileURL = urls.first else { return }
     
     // 检查文件扩展名（.up 或 .upex）
     let pathExtension = fileURL.pathExtension.lowercased()
     guard pathExtension == "up" || pathExtension == "upex" else {
         showAlert(message: "请选择.up或.upex格式的固件文件")
         return
     }
     
     // 获取文件访问权限
     guard fileURL.startAccessingSecurityScopedResource() else {
         showAlert(message: "无法访问文件")
         return
     }
     
     // ✅ 显示确认弹窗
     showConfirmAlert(for: fileURL)
 }
 
 // 确认弹窗
 private func showConfirmAlert(for fileURL: URL) {
     let fileName = fileURL.lastPathComponent
     let fileSize = getFileSize(fileURL)  // 格式化为 "1.25 MB"
     
     let message = """
     文件名: \(fileName)
     文件大小: \(fileSize)
     
     确定要开始 OTA 升级吗？
     升级过程中请保持设备连接。
     """
     
     let alert = UIAlertController(title: "确认升级", message: message, preferredStyle: .alert)
     
     // 取消按钮
     alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
         fileURL.stopAccessingSecurityScopedResource()
         self?.appendLog("ℹ️ 用户取消了 OTA 升级")
     })
     
     // 开始升级按钮
     alert.addAction(UIAlertAction(title: "开始升级", style: .default) { [weak self] _ in
         self?.startOTATransfer(with: fileURL)
     })
     
     present(alert, animated: true)
 }
 ```
 
 ### 5. OTA 传输实现
 
 ```swift
 private func startOTATransfer(with fileURL: URL) {
     currentFileURL = fileURL
     appendLog("📁 开始OTA升级: \(fileURL.lastPathComponent)")
     
     // 更新 UI
     DispatchQueue.main.async {
         self.startButton.isEnabled = false
         self.cancelButton.isEnabled = true
         self.progressView.progress = 0
         self.statusLabel.text = "准备中..."
     }
     
     // ✅ 禁用屏幕休眠（重要！避免升级期间锁屏）
     UIApplication.shared.isIdleTimerDisabled = true
     
     // 开始文件传输
     fileAppModel.startTransferFile(fileURL)
         .observe(on: MainScheduler.instance)
         .subscribe(
             onNext: { [weak self] progress in
                 // ✅ 检查失败状态
                 guard progress.isFail == false else {
                     self?.handleTransferError(progress.error ?? .mt(.other))
                     self?.currentFileURL?.stopAccessingSecurityScopedResource()
                     self?.currentFileURL = nil
                     UIApplication.shared.isIdleTimerDisabled = false
                     return
                 }
                 self?.handleProgress(progress)
             },
             onError: { [weak self] error in
                 self?.handleTransferError(error)
                 self?.currentFileURL?.stopAccessingSecurityScopedResource()
                 self?.currentFileURL = nil
                 UIApplication.shared.isIdleTimerDisabled = false
             },
             onCompleted: { [weak self] in
                 self?.handleTransferCompleted()
                 self?.currentFileURL?.stopAccessingSecurityScopedResource()
                 self?.currentFileURL = nil
                 UIApplication.shared.isIdleTimerDisabled = false
             }
         )
         .disposed(by: disposeBag)
 }
 ```
 
 ### 6. 进度处理
 
 ```swift
 private func handleProgress(_ progress: SJFileProgress) {
     DispatchQueue.main.async {
         // ✅ 注意：progress.progress 是 0-100 的值
         self.progressView.progress = Float(progress.progress / 100)
         
         let percentage = progress.progress
         let statusText = """
         传输中...
         进度: \(String(format: "%.1f", percentage))%
         文件: \(progress.currentIndex) / \(progress.totalCount)
         """
         self.statusLabel.text = statusText
         
         // 每 10% 记录一次日志
         if progress.progress > 0 && progress.progress < 100.0 {
             if Int(percentage) % 10 == 0 {
                 self.appendLog("📊 传输进度: \(String(format: "%.1f", percentage))%")
             }
         }
     }
 }
 ```
 
 ### 7. 三大代理协议实现
 
 #### 7.1 WMOtherDataDelegate（⚠️ 示例：接收蓝牙数据，需替换为您的实现）
 ```swift
 public func devicePushRawData(_ data: Data) {
     // 1. 解析 TLOCP 模型
     guard let model = TLOCPModel(data: data) else {
         appendLog("⚠️ 数据解析失败")
         return
     }
     
     // 2. ✅ 核心：传递给 MTWatchPeripheral（OTA SDK 必须）
     mtWatchPeripheral.fff2Data.accept(model)
     
     // 3. 打印日志（可选）
     DDLogInfo("📥 收到设备数据: sceneId=0x\(String(format: "%02X", model.sceneId))")
 }
 ```
 
 **⚠️ 集成说明**：
 - 这是示例代码，使用 `WMOtherDataDelegate` 接收数据
 - **集成到您的项目时**，用您自己的蓝牙数据接收方式替换
 - **核心要求**：从蓝牙接收到 `Data` 后，解析为 `TLOCPModel`，并调用 `mtWatchPeripheral.fff2Data.accept(model)`
 
 #### 7.2 MTWatchPeripheralDelegate（✅ OTA SDK：发送数据回调，必须实现）
 ```swift
 func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
     // 1. ⚠️ 使用您的蓝牙管理器发送到真实设备（此处使用 WatchManager 作为示例）
     WatchManager.sharedInstance().currentValue.sendIfNeed(data)
     
     // 2. 打印日志（可选）
     if let model = TLOCPModel(data: data) {
         DDLogInfo("📤 发送数据: sceneId=0x\(String(format: "%02X", model.sceneId))")
     }
 }
 ```
 
 **⚠️ 集成说明**：
 - 这是 OTA SDK 的回调，**必须实现**
 - **集成到您的项目时**，将 `WatchManager.sendIfNeed(data)` 替换为您自己的蓝牙发送方法
 - **核心要求**：收到 `data` 后，通过您的蓝牙管理器发送到设备
 
 #### 7.3 MTLogDelegate（✅ OTA SDK：日志回调，必须实现）
 ```swift
 func mtLog(level: MTLogLevel, message: String, file: String, line: Int) {
     // 1. 根据级别添加图标
     let icon: String
     switch level {
     case .debug: icon = "🔍"
     case .info: icon = "ℹ️"
     case .error: icon = "❌"
     }
     
     // 2. 提取文件名（不含路径）
     let fileName = (file as NSString).lastPathComponent
     
     // 3. 格式化并显示
     let logMessage = "\(icon) [\(fileName):\(line)] \(message)"
     appendLog(logMessage)
 }
 ```
 
 **✅ 集成说明**：
 - 这是 OTA SDK 的日志回调，**必须实现**
 - 接收所有 OTA SDK 内部的日志，方便调试
 - 您可以根据需要自定义日志格式和输出方式
 
 ### 8. 日志显示示例
 
 ```
 [14:25:30] ✅ 文件传输管理器初始化成功
 [14:25:35] 📁 开始OTA升级: firmware_v1.2.3.up
 [14:25:36] 🔍 [SJFileAppModel.swift:215] 开始传输文件
 [14:25:37] ℹ️ [SJSendFileTask.swift:98] 发送 Enable 命令
 [14:25:38] 📥 收到设备数据: sceneId=0x0E, commandId=0x8001
 [14:25:39] 🔍 [WatchPeripheral.swift:85] app->dev: 0E0A010203...
 [14:25:40] 📊 传输进度: 10.0%
 [14:25:45] 📊 传输进度: 50.0%
 [14:25:50] 🎉 OTA升级成功！
 ```
 
 ## 关键技术点
 
 ### 1. 屏幕休眠管理
 ```swift
 // 开始升级时禁用
 UIApplication.shared.isIdleTimerDisabled = true
 
 // 完成、失败或取消时恢复
 UIApplication.shared.isIdleTimerDisabled = false
 ```
 
 ### 2. 文件权限管理
 ```swift
 // 开始访问
 fileURL.startAccessingSecurityScopedResource()
 
 // 完成后释放
 fileURL.stopAccessingSecurityScopedResource()
 ```
 
 ### 3. 进度值处理
 ```swift
 // ⚠️ 注意：SJFileProgress.progress 是 0-100
 // UIProgressView.progress 需要 0.0-1.0
 progressView.progress = Float(progress.progress / 100)
 ```
 
 ### 4. 失败状态处理
 ```swift
 // ✅ 在 onNext 中检查 isFail 标志
 onNext: { progress in
     guard progress.isFail == false else {
         self?.handleTransferError(progress.error ?? .mt(.other))
         // 清理资源...
         return
     }
     self?.handleProgress(progress)
 }
 ```
 
 ## 清理资源（重要！）
 
 ```swift
 deinit {
     // ✅ 清理 MTLog 代理
     MTLog.delegate = nil
     MTLog.enableConsolePrint = true  // 恢复默认设置
     
     // ✅ 恢复屏幕休眠
     UIApplication.shared.isIdleTimerDisabled = false
     
     // ✅ 释放文件权限
     currentFileURL?.stopAccessingSecurityScopedResource()
 }
 ```
 
 ## 完整的最小集成示例（⚠️ 使用 WatchManager 作为示例）
 
 ```swift
 import UIKit
 import RxSwift
 
 // ⚠️ 此示例使用 WMOtherDataDelegate，集成时需要替换为您自己的蓝牙接收方式
 class MyOTAViewController: UIViewController, 
                           WMOtherDataDelegate,              // ⚠️ 需替换
                           MTWatchPeripheralDelegate,        // ✅ 必须实现
                           MTLogDelegate {                   // ✅ 必须实现
     
     // ✅ OTA SDK 核心组件
     let mtWatchPeripheral = MTWatchPeripheral()
     var fileAppModel: SJFileAppModel!
     let disposeBag = DisposeBag()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // ✅ 设置代理和初始化
         MTLog.delegate = self
         MTLog.enableConsolePrint = false
         mtWatchPeripheral.delegate = self
         fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)
         
         // ⚠️ 设置数据接收（使用 WatchManager 示例，需替换为您的蓝牙管理器）
         WatchManager.sharedInstance().current.subscribeNext { [weak self] peripheral in
             peripheral?.otherDataDelegate = self
         }
     }
     
     // ⚠️ 接收蓝牙数据（需替换为您的实现）
     public func devicePushRawData(_ data: Data) {
         guard let model = TLOCPModel(data: data) else { return }
         mtWatchPeripheral.fff2Data.accept(model)  // ✅ 核心：传递给 OTA SDK
     }
     
     // ✅ 发送蓝牙数据（OTA SDK 回调，必须实现）
     func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
         // ⚠️ 替换为您的蓝牙发送方法
         WatchManager.sharedInstance().currentValue.sendIfNeed(data)
     }
     
     // ✅ 日志回调（OTA SDK 回调，必须实现）
     func mtLog(level: MTLogLevel, message: String, file: String, line: Int) {
         print("[\((file as NSString).lastPathComponent):\(line)] \(message)")
     }
     
     // ✅ 开始 OTA
     func startOTA(fileURL: URL) {
         UIApplication.shared.isIdleTimerDisabled = true
         fileAppModel.startTransferFile(fileURL)
             .observe(on: MainScheduler.instance)
             .subscribe(
                 onNext: { progress in
                     print("进度: \(progress.progress)%")
                 },
                 onError: { error in
                     print("失败: \(error)")
                     UIApplication.shared.isIdleTimerDisabled = false
                 },
                 onCompleted: {
                     print("成功")
                     UIApplication.shared.isIdleTimerDisabled = false
                 }
             )
             .disposed(by: disposeBag)
     }
     
     // ✅ 清理资源
     deinit {
         MTLog.delegate = nil
         MTLog.enableConsolePrint = true
         UIApplication.shared.isIdleTimerDisabled = false
     }
 }
 ```
 
 ---
 
 ## 🔧 集成到您的项目
 
 ### 第一步：替换蓝牙数据接收
 
 **当前示例代码**：
 ```swift
 // ⚠️ 使用 WMOtherDataDelegate 和 WatchManager（需替换）
 class OTAExampleViewController: UIViewController, WMOtherDataDelegate {
     override func viewDidLoad() {
         super.viewDidLoad()
         // 设置 WatchManager 数据接收
         WatchManager.sharedInstance().current.subscribeNext { [weak self] peripheral in
             peripheral?.otherDataDelegate = self
         }
     }
     
     public func devicePushRawData(_ data: Data) {
         guard let model = TLOCPModel(data: data) else { return }
         mtWatchPeripheral.fff2Data.accept(model)
     }
 }
 ```
 
 **替换为您的蓝牙管理器**：
 ```swift
 // ✅ 使用您自己的蓝牙管理器
 class OTAExampleViewController: UIViewController, 
                                 MTWatchPeripheralDelegate,  // ✅ 必须
                                 MTLogDelegate {             // ✅ 必须
     
     // 假设您有自己的蓝牙管理器
     var myBluetoothManager: MyBluetoothManager!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // ✅ 设置您的蓝牙数据接收回调
         myBluetoothManager.onDataReceived = { [weak self] data in
             // 解析 TLOCP 模型
             guard let model = TLOCPModel(data: data) else { return }
             
             // ✅ 核心：传递给 OTA SDK
             self?.mtWatchPeripheral.fff2Data.accept(model)
         }
     }
 }
 ```
 
 **核心要求**：
 1. 从您的蓝牙设备接收原始 `Data`
 2. 解析为 `TLOCPModel(data: data)`
 3. 调用 `mtWatchPeripheral.fff2Data.accept(model)`
 
 ### 第二步：替换蓝牙数据发送
 
 **当前示例代码**：
 ```swift
 // ⚠️ 使用 WatchManager 发送数据（需替换）
 func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
     WatchManager.sharedInstance().currentValue.sendIfNeed(data)
 }
 ```
 
 **替换为您的蓝牙管理器**：
 ```swift
 // ✅ 使用您自己的蓝牙管理器发送
 func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
     // 使用您的蓝牙管理器发送数据
     myBluetoothManager.sendData(data)
     
     // 或者使用 CoreBluetooth
     myPeripheral.writeValue(data, for: myCharacteristic, type: .withoutResponse)
 }
 ```
 
 **核心要求**：
 1. 实现 `MTWatchPeripheralDelegate.watchPeripheral(_:needSendData:)` 方法
 2. 将 `data` 通过您的蓝牙管理器发送到设备
 
 ### 第三步：完整的集成示例
 
 ```swift
 import UIKit
 import RxSwift
 import CoreBluetooth  // 如果使用 CoreBluetooth
 
 class MyOTAViewController: UIViewController,
                           MTWatchPeripheralDelegate,   // ✅ 必须实现
                           MTLogDelegate {              // ✅ 必须实现
     
     // ✅ OTA SDK 核心组件
     let mtWatchPeripheral = MTWatchPeripheral()
     var fileAppModel: SJFileAppModel!
     let disposeBag = DisposeBag()
     
     // 您自己的蓝牙管理器
     var myBluetoothManager: MyBluetoothManager!
     
     override func viewDidLoad() {
         super.viewDidLoad()
         
         // ✅ 步骤 1: 设置 OTA SDK 代理
         MTLog.delegate = self
         MTLog.enableConsolePrint = false
         mtWatchPeripheral.delegate = self
         fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)
         
         // ✅ 步骤 2: 设置您的蓝牙数据接收
         setupBluetoothDataReceiving()
     }
     
     // ✅ 设置蓝牙数据接收（使用您自己的方式）
     private func setupBluetoothDataReceiving() {
         // 方式 1: 使用回调
         myBluetoothManager.onDataReceived = { [weak self] data in
             self?.handleBluetoothData(data)
         }
         
         // 方式 2: 使用通知
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleBluetoothNotification(_:)),
             name: .bluetoothDataReceived,
             object: nil
         )
         
         // 方式 3: 使用代理
         myBluetoothManager.delegate = self
     }
     
     // ✅ 处理蓝牙数据（核心方法）
     private func handleBluetoothData(_ data: Data) {
         // 1. 解析 TLOCP 模型
         guard let model = TLOCPModel(data: data) else {
             print("⚠️ TLOCP 数据解析失败")
             return
         }
         
         // 2. ✅ 传递给 OTA SDK（核心！）
         mtWatchPeripheral.fff2Data.accept(model)
     }
     
     // ✅ MTWatchPeripheralDelegate - 发送数据到设备
     func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
         // 使用您的蓝牙管理器发送
         myBluetoothManager.sendData(data)
     }
     
     // ✅ MTLogDelegate - 接收 OTA SDK 日志
     func mtLog(level: MTLogLevel, message: String, file: String, line: Int) {
         let fileName = (file as NSString).lastPathComponent
         print("[\(fileName):\(line)] \(message)")
     }
     
     // ✅ 开始 OTA 升级
     func startOTA(fileURL: URL) {
         UIApplication.shared.isIdleTimerDisabled = true
         
         fileAppModel.startTransferFile(fileURL)
             .observe(on: MainScheduler.instance)
             .subscribe(
                 onNext: { [weak self] progress in
                     guard progress.isFail == false else {
                         self?.handleError(progress.error)
                         return
                     }
                     self?.updateProgress(progress)
                 },
                 onError: { [weak self] error in
                     self?.handleError(error)
                     UIApplication.shared.isIdleTimerDisabled = false
                 },
                 onCompleted: { [weak self] in
                     self?.handleSuccess()
                     UIApplication.shared.isIdleTimerDisabled = false
                 }
             )
             .disposed(by: disposeBag)
     }
     
     private func updateProgress(_ progress: SJFileProgress) {
         print("进度: \(progress.progress)%")
     }
     
     private func handleError(_ error: Error?) {
         print("OTA 失败: \(error?.localizedDescription ?? "未知错误")")
     }
     
     private func handleSuccess() {
         print("OTA 升级成功！")
     }
     
     deinit {
         MTLog.delegate = nil
         MTLog.enableConsolePrint = true
         UIApplication.shared.isIdleTimerDisabled = false
     }
 }
 
 // ✅ 如果使用 CoreBluetooth
 extension MyOTAViewController: CBPeripheralDelegate {
     func peripheral(_ peripheral: CBPeripheral, 
                    didUpdateValueFor characteristic: CBCharacteristic, 
                    error: Error?) {
         guard let data = characteristic.value else { return }
         handleBluetoothData(data)  // ✅ 调用核心方法
     }
 }
 ```
 
 ### 核心集成要点
 
 | 步骤 | 说明 | 是否必须 |
 |------|------|----------|
 | 1. 创建 `MTWatchPeripheral` | `let mtWatchPeripheral = MTWatchPeripheral()` | ✅ 必须 |
 | 2. 设置发送代理 | `mtWatchPeripheral.delegate = self` | ✅ 必须 |
 | 3. 创建文件管理器 | `fileAppModel = SJFileAppModel(peripheral: mtWatchPeripheral)` | ✅ 必须 |
 | 4. 设置日志代理 | `MTLog.delegate = self` | ✅ 必须 |
 | 5. 接收蓝牙数据 | 解析后调用 `mtWatchPeripheral.fff2Data.accept(model)` | ✅ 必须 |
 | 6. 发送蓝牙数据 | 实现 `watchPeripheral(_:needSendData:)` | ✅ 必须 |
 | 7. 日志回调 | 实现 `mtLog(level:message:file:line:)` | ✅ 必须 |
 
 ### 常见集成场景
 
 #### 场景 1: 使用 CoreBluetooth
 ```swift
 func peripheral(_ peripheral: CBPeripheral, 
                didUpdateValueFor characteristic: CBCharacteristic, 
                error: Error?) {
     guard let data = characteristic.value,
           let model = TLOCPModel(data: data) else { return }
     mtWatchPeripheral.fff2Data.accept(model)  // ✅
 }
 
 func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
     cbPeripheral.writeValue(data, for: fff1Characteristic, type: .withoutResponse)  // ✅
 }
 ```
 
 #### 场景 2: 使用第三方蓝牙库
 ```swift
 // 例如：BabyBluetooth, BluetoothKit 等
 func onReceiveData(data: Data) {
     guard let model = TLOCPModel(data: data) else { return }
     mtWatchPeripheral.fff2Data.accept(model)  // ✅
 }
 
 func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data) {
     myBLEManager.write(data)  // ✅
 }
 ```
 
 #### 场景 3: 使用 RxBluetooth
 ```swift
 override func viewDidLoad() {
     super.viewDidLoad()
     
     // 订阅蓝牙数据
     myRxBluetooth.dataObservable
         .compactMap { TLOCPModel(data: $0) }
         .subscribe(onNext: { [weak self] model in
             self?.mtWatchPeripheral.fff2Data.accept(model)  // ✅
         })
         .disposed(by: disposeBag)
 }
 ```
 
 ## 注意事项
 
 ⚠️ **WatchManager 和 WMOtherDataDelegate 是外部依赖**：仅用于演示，集成时需替换  
 ⚠️ **必须实现两个 OTA SDK 代理**：MTWatchPeripheralDelegate、MTLogDelegate  
 ⚠️ **核心数据传递**：`mtWatchPeripheral.fff2Data.accept(model)` 必须调用  
 ⚠️ **进度值需要转换**：progress.progress 是 0-100，UIProgressView 需要 /100  
 ⚠️ **检查 isFail 标志**：在 onNext 中需要检查 progress.isFail  
 ⚠️ **管理屏幕休眠**：升级时禁用，完成后恢复  
 ⚠️ **管理文件权限**：startAccessingSecurityScopedResource 和 stopAccessingSecurityScopedResource  
 ⚠️ **清理代理**：deinit 中恢复 MTLog 默认设置  
 ⚠️ **使用 DisposeBag**：管理 RxSwift 订阅，避免内存泄漏  
 
 ## 优势总结
 
 | 特性 | 说明 |
 |------|------|
 | ✅ **完全解耦** | 通过代理协议清晰分离职责，易于替换蓝牙实现 |
 | ✅ **双向通信** | 设备到 App 和 App 到设备完整闭环 |
 | ✅ **日志统一** | 所有 SDK 日志回调到 UI，便于调试 |
 | ✅ **自动处理** | TLOCP 协议、分包、重传全自动 |
 | ✅ **用户友好** | 确认弹窗、进度显示、详细日志 |
 | ✅ **资源管理** | 自动管理文件权限和屏幕休眠 |
 | ✅ **易于集成** | 清晰的代码结构，容易理解和修改 |
 | ✅ **灵活适配** | 支持任何蓝牙管理实现（CoreBluetooth、第三方库等）|
 */

