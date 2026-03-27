//
//  SJFileAppModel.swift
//  SJWatchLib
//
//  Created by t_t on 2023/10/11.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit
import SwiftyJSON
import h264encoder
import AVFoundation
import SWCompression

// MARK: - Swift 进度模型

/// 文件传输进度模型（纯 Swift 实现）
struct SJFileProgress {
    /// 当前进度 (0.0 - 1.0)
    let progress: Double
    
    /// 当前文件索引（从1开始）
    let currentIndex: Int
    
    /// 总文件数
    let totalCount: Int
    
    /// 是否成功
    let isSuccess: Bool
    
    /// 是否失败
    let isFail: Bool
    
    /// 错误信息（如果有）
    let error: Error?
    
    /// 创建进行中的进度
    static func inProgress(_ progress: Double, current: Int = 1, total: Int = 1) -> SJFileProgress {
        return SJFileProgress(
            progress: progress,
            currentIndex: current,
            totalCount: total,
            isSuccess: false,
            isFail: false,
            error: nil
        )
    }
    
    /// 创建成功的进度
    static func success() -> SJFileProgress {
        return SJFileProgress(
            progress: 1.0,
            currentIndex: 1,
            totalCount: 1,
            isSuccess: true,
            isFail: false,
            error: nil
        )
    }
    
    /// 创建失败的进度
    static func failure(_ error: Error) -> SJFileProgress {
        return SJFileProgress(
            progress: 0.0,
            currentIndex: 1,
            totalCount: 1,
            isSuccess: false,
            isFail: true,
            error: error
        )
    }
}

// MARK: - Swift 错误类型

/// 文件传输错误（纯 Swift 实现）
enum SJFileTransferError: Error, LocalizedError {
    case busy                    // 设备忙
    case dialMax                 // 表盘达到上限
    case lowBattery             // 电量不足
    case lowStorage             // 存储空间不足
    case fileError              // 文件错误
    case fileDamaged            // 文件损坏
    case disconnect             // 设备断开
    case notEnoughSpace         // 空间不足
    case equipmentFailure       // 设备故障
    case unknown                // 未知错误
    case other(String)          // 其他错误
    
    var errorDescription: String? {
        switch self {
        case .busy: return "设备忙"
        case .dialMax: return "表盘已达上限"
        case .lowBattery: return "电量不足"
        case .lowStorage: return "存储空间不足"
        case .fileError: return "文件错误"
        case .fileDamaged: return "文件已损坏"
        case .disconnect: return "设备断开连接"
        case .notEnoughSpace: return "空间不足"
        case .equipmentFailure: return "设备故障"
        case .unknown: return "未知错误"
        case .other(let msg): return msg
        }
    }
}

// MARK: - 错误转换扩展

extension Error {
    /// 将旧的错误类型转换为新的 Swift 错误类型
    var toFileTransferError: SJFileTransferError {
        // 如果已经是 SJFileTransferError，直接返回
        if let fileError = self as? SJFileTransferError {
            return fileError
        }
        
        // 处理 SJSendFileEnableError
        if let enableError = self as? SJSendFileEnableError {
            switch enableError {
            case .busy:
                return .busy
            case .dialMax:
                return .dialMax
            case .lowBattery:
                return .lowBattery
            case .notEnoughSpace:
                return .notEnoughSpace
            case .other:
                return .other("发送文件错误")
            }
        }
        
        // 处理 SJSendFileCommand6Error
        if let command6Error = self as? SJSendFileCommand6Error {
            switch command6Error {
            case .notEnoughSpace:
                return .lowStorage
            case .equipmentFailure:
                return .equipmentFailure
            case .unknown:
                return .unknown
            }
        }
        
        // 默认返回未知错误
        return .other(self.localizedDescription)
    }
}

// MARK: - 文件传输类

/// 文件传输管理类（纯 Swift 实现）
class SJFileAppModel: NSObject {
    var disposeBag = DisposeBag()
    
    /// 蓝牙外设弱引用
    weak var peripheral: MTWatchPeripheral? {
        willSet {
            guard newValue != peripheral else { return }
        }
    }
    
    /// 初始化
    /// - Parameter peripheral: 蓝牙外设
    init(peripheral: MTWatchPeripheral? = nil) {
        super.init()
        self.peripheral = peripheral
    }
    
    var installDialDisposeBag = DisposeBag()
}

// MARK: - 文件类型扩展

extension String {
    /// 将文件扩展名转换为发送文件类型
    /// - Returns: 文件类型，如果不支持则返回 nil
    func toSendFileType() -> SJSendFileType? {
        let pathExtension = self.lowercased()
        
        if pathExtension == "up" {
            return .ota
        }
       
        if pathExtension == "upex" {
            return .upex
        }
        
        return nil
    }
}

// MARK: - 文件传输方法

extension SJFileAppModel {
    
    /// 检查是否支持文件传输
    /// - Returns: 是否支持
    func isSupport() -> Bool {
        return true
    }
    
    /// 开始传输文件（纯 Swift 实现，使用 RxSwift Observable）
    /// - Parameter file: 文件 URL
    /// - Returns: 返回进度的 Observable 流
    func startTransferFile(_ file: URL) -> Observable<SJFileProgress> {
        // 1. 读取文件并验证类型
        guard let data = try? Data(contentsOf: file),
              let sjType = file.pathExtension.toSendFileType() else {
            return .error(SJFileTransferError.fileError)
        }
        
        // 2. 检查 upex 文件完整性
        if sjType == .upex && !self.checkTarFileIntegrity(atData: data) {
            MTLog.debug("文件已损坏")
            return .error(SJFileTransferError.fileDamaged)
        }
        
        // 3. 创建文件模型
        let model = SJSendFileModel(data: data, name: file.pathComponents.last ?? "")
        
        // 4. 使用 Observable 代替 RACSignal
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(SJFileTransferError.disconnect)
                return Disposables.create()
            }
            
            guard let peripheral = self.peripheral else {
                observer.onError(SJFileTransferError.disconnect)
                return Disposables.create()
            }

            // 5. 开始文件传输任务
            let disposable = peripheral.sendFileTask
                .startTask(fileDatas: [model], type: sjType)
                .do(onSubscribe: {
                     // 可选：进入高速模式
                     self.peripheral?.enterHighSpeedMode()
                })
                .map { result -> SJFileProgress in
                    // result 是 (Bool?, Double, Int, Int, Error?) 元组
                    let isSuccess = result.0 ?? false
                    let progress = result.1
                    let error = result.4
                    
                    // 转换为 SJFileProgress
                    if isSuccess {
                        return .success()
                    } else if let error = error {
                        return .failure(error.toFileTransferError)
                    } else {
                        return .inProgress(progress, current: 1, total: 1)
                    }
                }
                .subscribe(
                    onNext: { progressModel in
                        if progressModel.isSuccess {
                            // 成功完成
                            observer.onNext(progressModel)
                            observer.onCompleted()
                        } else if progressModel.isFail {
                            // 失败
                            if let error = progressModel.error {
                                observer.onError(error)
                            } else {
                                observer.onError(SJFileTransferError.unknown)
                            }
                        } else {
                            // 进度更新
                            observer.onNext(progressModel)
                        }
                    },
                    onError: { error in
                        // 发送错误
                        observer.onError(error.toFileTransferError)
                    },
                    onCompleted: {
                        // 完成
                        observer.onCompleted()
                    }
                )
            
            // 6. 返回 Disposable，取消时清理资源
            return Disposables.create {
                disposable.dispose()
            }
        }
        .do(onError: { [weak self] _ in
            // 发生错误时取消传输
            self?.peripheral?.sendFileTask.cancelSendFile()
        })
    }
    
    /// 创建文件（如果不存在）
    /// - Parameter path: 文件路径
    func createFile(atPath path: String) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: path) {
            MTLog.debug("文件已存在: \(path)")
        } else {
            // 创建文件并检查创建是否成功
            if fileManager.createFile(atPath: path, contents: nil, attributes: nil) {
                MTLog.debug("创建文件成功: \(path)")
            } else {
                MTLog.debug("创建文件失败: \(path)")
            }
        }
    }
    
    /// 取消文件传输
    func cancelTransfer() {
        self.peripheral?.sendFileTask.cancelSendFile()
    }
}

// MARK: - 文件完整性检查

extension SJFileAppModel {
    /// 检查 tar 文件完整性（用于 .upex 文件）
    /// - Parameter data: 文件数据
    /// - Returns: 文件是否完整
    func checkTarFileIntegrity(atData data: Data) -> Bool {
        do {
            _ = try TarContainer.info(container: data)
        } catch {
            return false
        }
        return true
    }
}

