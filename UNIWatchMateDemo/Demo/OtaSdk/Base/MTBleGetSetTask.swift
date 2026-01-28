//
//  MTBleGetSetTask.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/12.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

protocol MTBleConvertToData{
    var toData:Data{get}
}

extension Bool: MTBleConvertToData {
    var to2Data: Data {
        return Data([(self ? 0x01:0x00)])
    }
}

extension Data: MTBleConvertToData {
    var toData: Data {
        return self
    }
}

class MTBleGetSetTask<T,M:MTBleConvertToData>: MTBleTask {
    var sceneId: Int {0}
    var commandId: Int {0}
    var isOnlyOne: Bool {true}
    var payLoad: Data? {nil}
    var timeout: Int {10}
    var desc: String {""}
    var isTasking: Bool = false
    var needRunNow: Bool {false}
    
    private var tagSceneId: Int {sceneId}
    private var tagCommandId: Int {commandId+0x8000}
    
    private var _event: Resolver<T>?
    
    func sendData(model:M?) -> Data {
        let payLoad = model?.toData ?? (self.payLoad ?? .init())
        let data = TLOCPModel.data(scene: sceneId, command: commandId, payLoad: payLoad)
        return data
    }
    
    func startTask(model:M? = nil, customTimeout:Int? = nil) -> Promise<T> {
        return .init {[weak self] event in
            guard let self = self, let ble = self.ble
//                    , ble.bleIsConnect.value
            else {
                event.reject(.mt(.disconnect))
                return
            }
            let tagSceneId = self.tagSceneId
            let tagCommandId = self.tagCommandId
            self.cancel()
            self._event = event
            
            if isOnlyOne {
                if self.isTasking && !self.needRunNow {
//                    event.reject(.mt(.commandRepeat))
                    return
                }
                if !self.needRunNow {
                    self.isTasking = true
                }
                MTLog.debug("old: \(self.desc) 准备中")
                    
                ble.sendResult(sceneId: tagSceneId, commandId: tagCommandId)
                    .timeout(.seconds(customTimeout ?? self.timeout), scheduler: MainScheduler.asyncInstance)
                    .take(1)
                    .do(onDispose: {[weak self] in
                        guard let self = self, !self.needRunNow else {return}
                        self.isTasking = false
                        self.ble?.semaphore.signal()
                    })
                    .subscribe(onNext: {[weak self] data in
                        guard let self = self else {return}
                        guard let info = self.decoder(payload: data) else {
                            event.reject(.mt(.commandFail(self.desc)))
                            MTLog.debug("old: \(self.desc) 失败")
                            return
                        }
                        event.fulfill(info)
                        MTLog.debug("old: \(self.desc) 成功")
                    }, onError: {[weak self] _ in
                        guard let self = self else {return}
                        let desc = self.desc
                        event.reject(.mt(.timeout(desc)))
                        MTLog.debug("old: \(self.desc) 超时")
                    })
                    .disposed(by: self.disposeBag)
            }else {
                ble.sendResult(sceneId: tagSceneId, commandId: tagCommandId)
                    .subscribe(onNext: {[weak self] data in
                        guard let self = self else {return}
                        guard let info = self.decoder(payload: data) else {
                            event.reject(.mt(.commandFail(self.desc)))
                            return
                        }
                        event.fulfill(info)
                    })
                    .disposed(by: self.disposeBag)
            }
            
            if isOnlyOne && !self.needRunNow {
                ble.semaphore_queue.async(execute: {
                    ble.semaphore.wait()
                    MTLog.debug("old: \(self.desc) 执行")
                    self.startSendData(model: model)
                })
            }else {
                MTLog.debug("old: \(self.desc) 执行")
                self.startSendData(model: model)
            }
        }
    }
    
    func startSendData(model:M?) {
        let data = self.sendData(model: model)
        self.ble?.otaManager( sendData: data)
    }
    
    func decoder(payload: Data) -> T? {
        return nil
    }
    
    override func cancel() {
        super.cancel()
        self._event = nil
    }
}
    
