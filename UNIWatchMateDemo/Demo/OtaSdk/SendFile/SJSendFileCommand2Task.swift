//
//  SJSendFileCommand2Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

struct SJSendFileCommand2Model {
    var size: UInt32
    var name: String
}

extension SJSendFileCommand2Model: MTBleConvertToData {
    var toData: Data {
        var size = self.size
        var data = Data(bytes: &size, count: 4)
        data += name.data(using: .utf8)!
        return data
    }
}

class SJSendFileCommand2Task: MTBleGetSetTask<Int, SJSendFileCommand2Model> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0002}
    override var desc: String {"0e 0002"}
    
    override func decoder(payload: Data) -> Int? {
        guard payload.count == 4 else {return nil}
        var mtu: Int = 0
        (payload as NSData).getBytes(&mtu, length: 4)
        if mtu > 10 {return mtu}
        return nil
    }
}
