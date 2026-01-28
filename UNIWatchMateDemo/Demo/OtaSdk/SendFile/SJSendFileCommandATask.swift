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


struct SJSendFileCommandAModel {
    var type: SJSendFileType
    var size: UInt32
    var count: UInt8
    var attachmentSize: UInt32 = 0
    var crcArray: [Data] = []
}

extension SJSendFileCommandAModel: MTBleConvertToData {
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
        for crc in self.crcArray {
            data += crc
        }
        return data
    }
}



struct SJSendFileCommandAResponseModel {
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

class SJSendFileCommandATask: MTBleGetSetTask<SJSendFileCommandAResponseModel, SJSendFileCommandAModel> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x000A}
    override var desc: String {"0e 000A"}
    
    override func startSendData(model:SJSendFileCommandAModel?) {
        let data = self.sendData(model: model)
        self.ble?.sendIfNeed(data)
    }
    
    override func decoder(payload: Data) -> SJSendFileCommandAResponseModel? {
        return .init(data: payload)
    }
}
