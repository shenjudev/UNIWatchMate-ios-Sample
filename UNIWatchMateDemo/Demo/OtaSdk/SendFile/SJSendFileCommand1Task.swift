//
//  SJSendFileCommand1Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

enum SJSendFileType: UInt8 {
    case audio = 1
    case ota = 2
    case bin = 3
    case jpg = 4
    case upex = 5
    case txt = 6
    case avi = 7
}

struct SJSendFileCommand1Model {
    var type: SJSendFileType
    var size: UInt32
    var count: UInt8
    var attachmentSize: UInt32 = 0
}

extension SJSendFileCommand1Model: MTBleConvertToData {
    var toData: Data {
        var data = Data([self.type.rawValue])
        var size: Int
        if type == .ota || type == .upex{
            size = -1
        }else {
            size = Int(self.size)
        }
        data += Data(bytes: &size, count: 4)
        data += Data([self.count])
        var attachmentSize = self.attachmentSize
        data += Data(bytes: &attachmentSize, count: 4)
        return data
    }
}

enum SJSendFileEnableError: UInt8, Error {
    case busy = 1
    case notEnoughSpace = 2
    case dialMax = 3
    case lowBattery = 4
    case other = 5
    
    init?(value: UInt8) {
        if value >= 5 || value == 0 {
            self = .other
        }else {
            self.init(rawValue: value)
        }
    }
}

struct SJSendFileCommand1ResponseModel {
    var isEnable: Bool
    var error: SJSendFileEnableError?
    
    init?(data: Data) {
        guard data.count == 2 else {return nil}
        self.isEnable = data[0] == 1
        self.error = .init(value: data[1])
        if data[1] != 0 {
            MTLog.debug("ota 01 error code(\(self.error?.rawValue ?? 5))")
        }
    }
}

class SJSendFileCommand1Task: MTBleGetSetTask<SJSendFileCommand1ResponseModel, SJSendFileCommand1Model> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0001}
    override var desc: String {"0e 0001"}
    
    override func startSendData(model:SJSendFileCommand1Model?) {
        let data = self.sendData(model: model)
        self.ble?.sendIfNeed(data)
    }
    
    override func decoder(payload: Data) -> SJSendFileCommand1ResponseModel? {
        return .init(data: payload)
    }
}
