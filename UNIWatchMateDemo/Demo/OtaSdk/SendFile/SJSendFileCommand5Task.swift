//
//  SJSendFileCommand5Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

class SJSendFileCommand5Task: MTBleGetSetTask<Bool, Bool> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0005}
    override var desc: String {"0e 0005"}
    
    override func decoder(payload: Data) -> Bool? {
        guard payload.count == 1, payload[0] == 1 else {return nil}
        return true
    }
}
