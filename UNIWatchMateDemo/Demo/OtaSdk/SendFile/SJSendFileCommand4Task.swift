//
//  SJSendFileCommand4Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

class SJSendFileCommand4Task: MTBleMonitorTask<Bool> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0004}
    
    override func decoder(payload: Data) -> Bool? {
        guard payload.count == 1 else {return nil}
        return payload[0] == 1
    }
}
