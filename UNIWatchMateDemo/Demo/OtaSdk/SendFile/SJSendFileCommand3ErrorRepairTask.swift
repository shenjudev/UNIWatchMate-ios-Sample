//
//  SJSendFileCommand3ErrorRepairTask.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

class SJSendFileCommand3ErrorRepairTask: MTBleTask {
    
    func sendData(data: Data, index: Int, count: Int, error: @escaping () -> Void) {
        guard let ble = self.ble,  count < 100 else {
            error()
            return
        }
        
        ble.sendIfNeed(data)
        MTLog.debug("纠错第\(index)包数据，\(count)次，data:\(data.toHexString())")
        
        Observable.just(0).delay(.milliseconds(500), scheduler: MainScheduler.asyncInstance).bind {[weak self] _ in
            guard let self = self else {
                error()
                return
            }
            self.sendData(data: data, index: index, count: count+1, error: error)
        }
        .disposed(by: self.disposeBag)
    }
    
    func startTask(data: Data, index: Int) -> Observable<Bool> {
        return .create {[weak self] observer in
            guard let self = self, let ble = self.ble else {
                return Disposables.create()
            }
            
            ble.sendResult(sceneId: 0x0e, commandId: 0x8003)
                .subscribe(onNext: {[weak self] data in
                    guard let model = SJSendFileCommand3ResponseModel(data: data),
                          model.index == index,
                          model.isSuccess else {return}
                    observer.onNext(true)
                    self?.cancel()
                }, onError: { error in
                    observer.onError(error)
                })
                .disposed(by: self.disposeBag)
            
            self.sendData(data: data, index: index, count: 0) {
                observer.onError(.mt(.disconnect))
            }
            
            return Disposables.create {[weak self] in
                self?.cancel()
            }
        }
    }
}
