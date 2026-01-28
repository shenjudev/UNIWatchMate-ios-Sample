//
//  MTBleGetSetTask.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/12.
//

import Foundation
import RxSwift
import RxCocoa
import PromiseKit



class MTBleOnlySetTask<T,M:MTBleConvertToData>: MTBleTask {
    var sceneId: Int {0}
    var commandId: Int {0}
    var payLoad: Data? {nil}
    var desc: String {""}
    
    
    func sendData(model:M?) -> Data {
        let payLoad = model?.toData ?? (self.payLoad ?? .init())
        let data = TLOCPModel.data(scene: sceneId, command: commandId, payLoad: payLoad)
        return data
    }
    
    func startTask(model:M? = nil, customTimeout:Int? = nil)  {
            
            self.cancel()
            MTLog.info("old:MTBleOnlySetTask \(self.desc) 执行")
            self.startSendData(model: model)
    }
    
    func startSendData(model:M?) {
        let data = self.sendData(model: model)
    }

    
    override func cancel() {
        super.cancel()
    }
}
    
