//
//  SJSendFileCommand3ResponseTask.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

struct SJSendFileCommand3ResponseModel {
    var isSuccess: Bool
    var index: Int
    
    init?(data: Data) {
        guard data.count == 5 else {return nil}
        let indexData = Data(data[1..<5])
        var index: Int = 0
        (indexData as NSData).getBytes(&index, length: 4)
        self.isSuccess = data[0] == 1
        self.index = index
    }
}

class SJSendFileCommand3ResponseTask: MTBleMonitorTask<SJSendFileCommand3ResponseModel> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0003}
    override var timeout: Int {60*60*60}
    
    override func decoder(payload: Data) -> SJSendFileCommand3ResponseModel? {
        return .init(data: payload)
    }
}
