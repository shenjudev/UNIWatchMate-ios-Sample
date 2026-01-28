//
//  WatchPeripheral.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/12.
//

import Foundation
import CoreBluetooth
import RxSwift
import RxCocoa
import PromiseKit


// MARK: - MTWatchPeripheral 代理协议

/// MTWatchPeripheral 数据发送代理
/// 用于将数据发送请求回调到 ViewController
protocol MTWatchPeripheralDelegate: AnyObject {
    /// 需要发送数据到设备
    /// - Parameter data: 要发送的数据
    func watchPeripheral(_ peripheral: MTWatchPeripheral, needSendData data: Data)
}

// MARK: - MTWatchPeripheral 类

class MTWatchPeripheral: NSObject, WatchPeripheral {
    
    /// 文件传输任务管理器
    lazy var sendFileTask = SJSendFileTask(ble: self)
    lazy var highSpeedModeTask2 = SJ2WatchHighSpeedModeTask(ble: self)
    var tlocp2HandlerDisposeBag = DisposeBag()

    /// 代理（用于回调数据发送）
    weak var delegate: MTWatchPeripheralDelegate?
    
    /// OTA 管理器需要发送数据时调用
    /// - Parameter data: 要发送的数据
    /// - Note: 此方法会通过代理回调到 ViewController
    func otaManager(sendData data: Data) {
        // 通过代理回调到 ViewController
        delegate?.watchPeripheral(self, needSendData: data)
    }
    typealias TLOCP2GroupResult = (id:UInt16, model:TLOCP2PackageModel)

    /// 接收到的 TLOCP 数据流
    let fff2Data = PublishRelay<TLOCPModel>()
    let tlocp2Response = PublishRelay<TLOCP2GroupResult>()

    /// 信号量（用于线程同步）
    let semaphore = DispatchSemaphore(value: 1)
    
    /// 信号量队列
    let semaphore_queue = DispatchQueue(label: "sj_semaphore_queue")
    
    override init() {
        super.init()
        self.tlocp2ResponseHandler()
    }
    
    func tlocp2ResponseHandler() {
        var tmp = [UInt16: Data]()
        
        self.sendResult(sceneId: 0x30, commandId: 0x8002)
            .compactMap{PayloadPackage.decoder(payload: $0)}
            .observe(on: MainScheduler.asyncInstance)
            .bind {[weak self] pmodel in
                guard let self = self else {return}
                
                if var data = tmp[pmodel.id] {
                    data.append(pmodel.data)
                    tmp[pmodel.id] = data
                }else {
                    tmp[pmodel.id] = pmodel.data
                }
                
                if pmodel.index == .max {
                    let data = Data(tmp[pmodel.id]!)
                    if let rs = PayloadPackage.decoder(rawData: data) {
                        self.tlocp2Response.accept((pmodel.id, rs))
                    }
                    tmp[pmodel.id] = nil
                }
            }
            .disposed(by: self.tlocp2HandlerDisposeBag)
    }
    
    
    func enterHighSpeedMode() {
        firstly {
            self.highSpeedModeTask2.execute(model: .init())
        }
        .done { _ in

        }
        .catch { error in

        }
    }
}

// MARK: - WatchPeripheral 协议

/// 蓝牙外设协议
protocol WatchPeripheral: NSObject {
    /// OTA 管理器发送数据
    /// - Parameter data: 要发送的数据
    func otaManager(sendData data: Data)
    
    /// 接收到的 TLOCP 数据流
    var fff2Data: PublishRelay<TLOCPModel> { get }
}

// MARK: - WatchPeripheral 扩展

extension WatchPeripheral {
    
    
    
    /// 发送数据（如果需要）
    /// - Parameter data: 要发送的数据
    /// - Note: 此方法会根据数据类型决定是否打印日志
    func sendIfNeed(_ data: Data) {
        // 解析 TLOCP 模型，如果是文件数据传输（0x0E 场景，0x0003 命令）则不打印日志
        if let model = TLOCPModel(data: data),
           model.sceneId == 0x0e,
           model.commandId == 0x0003 {
            // 文件数据传输，不打印日志（避免日志过多）
        } else {
            // 其他数据，打印日志
            MTLog.info("app->dev: \(data.toHexString())")
        }
        
        // 实际发送逻辑（需要在具体实现中完成）
        // self.peripheral.writeValue(data, for: fff1Characteristic, type: .withoutResponse)
        
        // 调用 otaManager 发送数据
        otaManager(sendData: data)
    }
    
    /// 等待指定场景和命令的响应数据
    /// - Parameters:
    ///   - sceneId: 场景ID
    ///   - commandId: 命令ID
    /// - Returns: 返回响应数据的 Observable 流
    /// - Note: 此方法会过滤 fff2Data 流，只返回匹配的场景和命令的数据
    func sendResult(sceneId: Int, commandId: Int) -> Observable<Data> {
        var data = Data()
        var index: UInt8? = nil
        var errorOccur = false
        
        return Observable<Data>.create { [weak self] sender in
            return self!.fff2Data
                .map { model in
                    // 错误检测：检查序列号是否连续
                    if model.sceneId == 0x1e && commandId == 0x8001 {
                        if model.sceneId == 0x1e {
                            if index != nil && model.serialNumber != index {
                                // 序列号不连续，说明有错包
                                index = nil
                                errorOccur = true
                                MTLog.info("errorOccur: index != nil && serialNumber != index")
                                MTLog.info("dev->app: commandId = \(model.commandId)")
                                MTLog.info("dev->app: index = \(String(describing: index))")
                                MTLog.info("dev->app: serialNumber = \(model.serialNumber)")
                                MTLog.info("dev->app: payload.count = \(model.payload.count)")
                                MTLog.info("dev->app: model.type = \(model.type)")
                            }
                        }
                    }
                    return model
                }
                .filter { $0.sceneId == sceneId && $0.commandId == commandId }
                .filter { $0.serialNumber == index || index == nil }
                .subscribe(
                    onNext: { model in
                        // 处理空负载
                        guard model.payload.count > 0 else {
                            index = nil
                            if model.type == .none {
                                sender.onNext(data)
                                data = .init()
                            } else {
                                MTLog.info("dev->app: model.payload.count == 0, type = \(model.type)")
                            }
                            return
                        }
                        
                        // 根据分包类型处理数据
                        if model.type == .none {
                            // 单包数据
                            index = nil
                            if sceneId == 0x2b && commandId == 0x8001 {
                                data.append(model.serialNumber)
                            }
                            if model.payload.count > 0 {
                                data.append(model.payload[0..<model.payload.count])
                            }
                            sender.onNext(data)
                            data = .init()
                        } else if model.type == .footer {
                            // 尾包数据
                            index = nil
                            if model.sceneId == 0x30 {
                                data.append(model.payload[0..<model.payload.count])
                            } else if model.payload.count > 4 {
                                if model.sceneId == 0x1e {
                                    data.append(model.payload[4..<model.payload.count])
                                } else {
                                    data.append(model.payload[4..<model.payload.count])
                                }
                            }
                            if !errorOccur {
                                sender.onNext(data)
                            } else {
                                MTLog.info("dev->app: type = \(model.type), errorOccur = \(errorOccur)")
                            }
                            data = .init()
                        } else {
                            // 首包或中间包数据
                            if model.type == .header {
                                errorOccur = false
                                index = model.serialNumber
                            } else {
                                if data.count == 0 {
                                    index = model.serialNumber
                                    MTLog.info("dev->app: errorOccur (没有收到首包)")
                                    errorOccur = true
                                }
                            }
                            
                            if model.sceneId == 0x30 {
                                data.append(model.payload[0..<model.payload.count])
                            } else if model.payload.count > 4 {
                                if model.sceneId == 0x1e {
                                    data.append(model.payload[4..<model.payload.count])
                                } else {
                                    data.append(model.payload[4..<model.payload.count])
                                }
                            }
                        }
                    },
                    onError: { error in
                        sender.onError(error)
                        data = .init()
                    }
                )
        }
    }
}
