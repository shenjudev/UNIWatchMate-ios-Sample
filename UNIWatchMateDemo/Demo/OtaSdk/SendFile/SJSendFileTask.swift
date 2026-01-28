//
//  SJSendFileTask.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

struct SJSendFileModel {
    var data: Data
    var name: String
}

class SJSendFileTask: MTBleTask {
    let index = BehaviorRelay<Int>(value: 0)
    let progress = BehaviorRelay<Double>(value: 0)
    let sendResult = BehaviorRelay<(Bool?, Error?)?>(value: nil)
    
    
    lazy var command1Task = SJSendFileCommand1Task(ble: ble!)
    lazy var commandATask = SJSendFileCommandATask(ble: ble!)
    lazy var command2Task = SJSendFileCommand2Task(ble: ble!)

    lazy var sendBoayTask = SJSendFileCommand3Task(ble: ble!)
    lazy var bodyResponseTask = SJSendFileCommand3ResponseTask(ble: ble!)
    lazy var errorRepairTask = SJSendFileCommand3ErrorRepairTask(ble: ble!)
    
    lazy var resultTask = SJSendFileCommand4Task(ble: ble!)
    lazy var cancelTask = SJSendFileCommand5Task(ble: ble!)
    lazy var notifyWhen0ATimeoutTask = SJSendFileCommand8Task(ble: ble!)

    lazy var deviceCancelTask = SJSendFileCommand6Task(ble: ble!)
    
    var fileDatas = [SJSendFileModel]()
    var mtu = 0;
    
    var installUUID = UUID()
    //
    var sendBodyProgressDisposeBag = DisposeBag()
    var bodyResponseDisposeBag = DisposeBag()
    var resultDisposeBag = DisposeBag()
    var deviceCancelDisposeBag = DisposeBag()
    
    let stopSendTask = PublishRelay<Void>()
    
    typealias SendFileTaskResponse = (Bool?, Double, Int, String, Error?)
    
    override func bleDisconnectHandler() {
        
    }
    
    override func cancel() {
        super.cancel()
        self.command1Task.cancel()
        self.commandATask.cancel()
        self.command2Task.cancel()
        self.sendBoayTask.cancel()
        self.bodyResponseTask.cancel()
        self.errorRepairTask.cancel()
        self.resultTask.cancel()
        self.cancelTask.cancel()
        self.deviceCancelTask.cancel()
        
        self.sendBodyProgressDisposeBag = .init()
        self.bodyResponseDisposeBag = .init()
        self.resultDisposeBag = .init()
        self.deviceCancelDisposeBag = .init()
        
        self.fileDatas = .init()
        self.mtu = 0
        self.index.accept(0)
        self.progress.accept(0)
        self.sendResult.accept(nil)
        self.stopSendTask.accept(())
        
        self.installUUID = .init()
        
        MTLog.debug("重置文件传输环境")
    }
}

extension SJSendFileTask {
    
    func startTask(fileDatas: [SJSendFileModel], type: SJSendFileType, attachmentSize: Int = 0) -> Observable<SendFileTaskResponse> {
        guard fileDatas.count > 0 else {return .just((false, 0, 0, "", .mt(.urlError)))}
        self.cancel()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.fileDatas = fileDatas
            
            let size = fileDatas.reduce(0, {$0+$1.data.count})
            if type == .ota || type == .upex{
                var crcArray: [Data] = []
                for fileData in fileDatas {
                    // 获取文件数据
                    let data = fileData.data
                    MTLog.debug("OTA文件大小: \(data.count) bytes")
                    // 使用大数据量CRC16计算方法,初始值为0xFFFF
                    let crcData = UNIOTABtUtils.watchCrc16BigData(data, result: 0xFFFF) as Data?
                    guard let  crcData = crcData else{
                        MTLog.debug("OTA文件CRC16计算失败")
//                        self.sendResult.accept((false, .toWmError(.other)))
                        self.cancel()
                        return
                    }
                    // 计算CRC16校验值,初始值为0xFFFF
                    MTLog.info("OTA文件CRC16校验数据: \(crcData.map { String(format: "%02X", $0) }.joined())")
                    
                    // 将CRC值添加到数组中
                    crcArray.append(crcData)
                }
                let modelA = SJSendFileCommandAModel(type: type, size: .init(size), count: .init(fileDatas.count), attachmentSize: UInt32(attachmentSize),crcArray:crcArray)
                
                firstly {
                    self.commandATask.startTask(model: modelA)
                }
                .done { model  in
                    if model.isEnable {
                        self.resultMonitor()
                        self.deviceCancelMonitor()
                        self.sendBodyProgressMonitor()
                        self.startSendFile(index: 0)
                    }else {
                        self.sendResult.accept((false, model.error))
                        self.cancel()
                    }
                }
                .catch { [weak self] error in
                    guard let self = self else {
                        return
                    }
                    //咋样判断是0A命令的timeout  "0e 000A"
                    // 如果需要获取 timeout 的关联值
                    if case MTError.timeout(let message) = error as! MTError {
                        if message == self.commandATask.desc {
                            MTLog.info("commandATask 超时错误信息: \(message)")

                            self.notifyWhen0ATimeoutTask.startTask()
                        }
                    }
                    self.sendResult.accept((false, error))
                    self.cancel()
                }
            }else {
                let model1 = SJSendFileCommand1Model(type: type, size: .init(size), count: .init(fileDatas.count), attachmentSize: UInt32(attachmentSize))
                
                firstly {
                    self.command1Task.startTask(model: model1)
                }
                .done { model  in
                    if model.isEnable {
                        self.resultMonitor()
                        self.deviceCancelMonitor()
                        self.sendBodyProgressMonitor()
                        self.startSendFile(index: 0)
                    }else {
                        self.sendResult.accept((false, model.error))
                        self.cancel()
                    }
                }
                .catch { error in
                    self.sendResult.accept((false, error))
                    self.cancel()
                }
            }
           
            
//            self.ble?.bleIsConnect.filter{!$0}.take(1).bind {[weak self] _ in
//                self?.sendResult.accept((false, .mt(.disconnect)))
//            }.disposed(by: self.disposeBag)
        }
        
        return Observable.combineLatest(self.sendResult.compactMap{$0}.startWith((nil, nil)), self.progress.startWith(0), self.index.startWith(0))
            .map{($0.0, $1, $2, fileDatas[$2].name, $0.1)}
            .take(until: self.stopSendTask)
            .share(replay: 1)
//            .debug()
    }
    
    func startSendFile(index: Int) {
        MTLog.debug("开始发送第\(index)个文件")
        let model2 = SJSendFileCommand2Model(size: .init(self.fileDatas[index].data.count),
                                             name: self.fileDatas[index].name)
        
        firstly {
            self.command2Task.startTask(model: model2)
        }
        .done { mtu in
            self.mtu = mtu
            self.startSendBody(fileData: self.fileDatas[index])
        }
        .catch { error in
            self.sendResult.accept((false, error))
            self.cancel()
        }
    }
    
    func startSendBody(fileData: SJSendFileModel) {
        MTLog.debug("开始进行数据分包")
        var uuid = UUID()
        self.installUUID = uuid
        
        self.sendBoayTask.install(fileData: fileData.data, mtu: self.mtu) {[weak self] in
            if self?.installUUID != uuid {
                return
            }
            self?.sendBody(index: 0)
        }
    }
    
    func sendBody(index: Int) {
        MTLog.debug("从\(index)包开始发送文件")
        self.sendErrorMonitor()
        self.sendBoayTask.disposeBag = .init()
        self.sendBoayTask.isCancelTask = false
        self.sendBoayTask.sendData(index: index)
    }
    
    func sendErrorRepair(index: Int) {
        guard index < self.sendBoayTask.datas.count else {return}
        MTLog.debug("开始纠错：\(index)")
        
        let fileData = self.sendBoayTask.datas[index]
        self.errorRepairTask.cancel()
        self.errorRepairTask.startTask(data: fileData, index: index).take(1).subscribe {[weak self] _ in
            guard let self = self else {return}
            MTLog.debug("第 \(index) 纠错成功")
            self.sendBody(index: index+1)
        } onError: {[weak self] error in
            MTLog.debug("纠错失败，传输失败")
            self?.sendResult.accept((false, error))
            self?.cancel()
        }
        .disposed(by: self.disposeBag)
    }
    
    func cancelSendFile() {
        self.sendResult.accept((false, .mt(.commandFail("取消发送"))))
        self.stopSendTask.accept(())
        self.cancel()
        firstly {
            self.cancelTask.startTask()
        }
        .done {_ in }.catch{_ in }
        .finally {
            self.sendResult.accept((false, .mt(.cancel)))
        }
    }
    
    func sendBodyProgressMonitor() {
        self.sendBodyProgressDisposeBag = .init()
        
        self.sendBoayTask.progress.bind {[weak self] progress in
            self?.progress.accept(progress)
        }
        .disposed(by: self.sendBodyProgressDisposeBag)
    }
    
    func sendErrorMonitor() {
        self.bodyResponseTask.cancel()
        self.bodyResponseTask.startTask()
        self.bodyResponseDisposeBag = .init()
        
        self.bodyResponseTask.publishResponse.bind {[weak self] model in
            guard let self = self, !model.isSuccess else {return}
            MTLog.debug("第\(model.index)错误，开始纠错")
            self.sendErrorRepair(index: model.index)
            self.bodyResponseDisposeBag = .init()
            self.sendBoayTask.disposeBag = .init()
            self.sendBoayTask.isCancelTask = true
        }
        .disposed(by: self.bodyResponseDisposeBag)
    }
    
    func resultMonitor() {
        self.resultTask.cancel()
        self.resultTask.startTask()
        self.resultDisposeBag = .init()
        
        self.resultTask.publishResponse.bind {[weak self] isSuccess in
            guard let self = self else {return}
            
            if !isSuccess {
                self.sendResult.accept((false, .mt(.commandFail("发送失败"))))
                self.stopSendTask.accept(())
                self.cancel()
                return
            }

            if self.index.value+1 == self.fileDatas.count {
                MTLog.debug("文件发送完成")
                self.sendResult.accept((true, nil))
                self.stopSendTask.accept(())
                self.cancel()
            }else {
                let index = self.index.value+1
                self.index.accept(index)
                self.startSendFile(index: index)
            }
        }
        .disposed(by: self.resultDisposeBag)
    }
    
    func deviceCancelMonitor() {
        self.deviceCancelTask.cancel()
        self.deviceCancelTask.startTask()
        self.deviceCancelDisposeBag = .init()
        
        self.deviceCancelTask.publishResponse.bind {[weak self] error in
            guard let self = self else {return}
            MTLog.debug("设备取消发送")
            self.sendResult.accept((false, error))
            self.cancel()
        }
        .disposed(by: self.deviceCancelDisposeBag)
    }
}
