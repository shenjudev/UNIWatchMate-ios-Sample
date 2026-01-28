//
//  MTBleMonitorTask.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/12.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

@objc protocol SJResponseToWatchDelegate {
    func response(sceneId: Int, commandId: Int, data: Any?, response: @escaping (Data?) -> Void)
}

extension SJResponseToWatchDelegate {
    func response(sceneId: Int, commandId: Int, data: Any?, response: @escaping (Data?) -> Void) {
        
    }
}

class MTBleMonitorTask<T>: MTBleTask {
    var desc: String {""}
    var timeout: Int {3}
    let response = BehaviorRelay<T?>(value: nil)
    let publishResponse = PublishRelay<T>()
    
    var sceneId: Int {0}
    var commandId: Int {0}
    
    private var tagSceneId: Int {sceneId}
    private var tagCommandId: Int {commandId+0x8000}
    
    private var singleDisposeBag = DisposeBag()
    
    weak var delegate: MTWatchPeripheral?
    
    override init(ble: MTWatchPeripheral) {
        super.init(ble: ble)
        self.delegate = ble
    }
    
    func startTask() {
        guard let ble = self.ble else {return}
        self.disposeBag = .init()
        
        let tagSceneId = self.tagSceneId
        let tagCommandId = self.tagCommandId
        
    ble.sendResult(sceneId: tagSceneId, commandId: tagCommandId)
            .subscribe(onNext: {[weak self] data in
                guard let self = self, let info = self.decoder(payload: data) else {
                    return
                }
                self.response.accept(info)
                self.publishResponse.accept(info)
                self.responseToWatch(model: info)
            })
            .disposed(by: self.disposeBag)
    }
    
    func startTaskSingle() -> Promise<T> {
        self.singleDisposeBag = .init()
        
        return .init {[weak self] event in
            guard let self = self, let ble = self.ble else {
                event.reject(.mt(.disconnect))
                return
            }
            let tagSceneId = self.tagSceneId
            let tagCommandId = self.tagCommandId
            
            ble.sendResult(sceneId: tagSceneId, commandId: tagCommandId)
                .take(1)
                .timeout(.seconds(timeout), scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: {[weak self] data in
                    guard let self = self, let info = self.decoder(payload: data) else {return}
                    event.fulfill(info)
                    self.responseToWatch(model: info)
                }, onError: {[weak self] _ in
                    let desc = self?.desc ?? ""
                    event.reject(.mt(.timeout(desc)))
                })
                .disposed(by: self.singleDisposeBag)
        }
    }
    
    func responseToWatch(model: T) {
        //发个消息后
//        self.delegate?.response(sceneId: self.sceneId, commandId: self.commandId, data: model, response: {[weak self] data in
//            guard let self = self, let payload = data else {return}
//            let data = TLOCPModel.data(scene: self.sceneId, command: self.commandId, payLoad: payload)
//            self.ble?.sendIfNeed(data)
//        })
    }
    
    func decoder(payload: Data) -> T? {
        return nil
    }
    
    override func cancel() {
        super.cancel()
        self.singleDisposeBag = .init()
    }
}
