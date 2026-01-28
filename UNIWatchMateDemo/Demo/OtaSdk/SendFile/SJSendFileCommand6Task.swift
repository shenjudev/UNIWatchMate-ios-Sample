//
//  SJSendFileCommand6Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

enum SJSendFileCommand6Error: UInt8, Error {
    case unknown = 0
    case notEnoughSpace = 1
    case equipmentFailure = 2
}

class SJSendFileCommand6Task: MTBleMonitorTask<Error> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0006}
    
    override func decoder(payload: Data) -> Error? {
        guard payload.count == 1 else {return nil}
        return SJSendFileCommand6Error.init(rawValue: payload[0])
    }
}
