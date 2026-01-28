//
//  MTBleTask.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/12.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit

class MTBleTask {
    weak var ble: MTWatchPeripheral?
    var disposeBag = DisposeBag()
    
    let bleDisposeBag = DisposeBag()
    init(ble: MTWatchPeripheral) {
        self.ble = ble
//        ble.bleIsConnect.filter{!$0}.bind {[weak self] _ in
//            self?.bleDisconnectHandler()
//        }.disposed(by: self.bleDisposeBag)
    }
    
    func bleDisconnectHandler() {
        self.cancel()
    }
    
    func cancel() {
        self.disposeBag = .init()
    }
    
}
