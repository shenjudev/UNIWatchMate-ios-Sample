//
//  SJSendFileCommand3Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

var modelName: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}

class SJSendFileCommand3Task: MTBleTask {
    var datas = [Data]()
    var mtu = 0
    var fileData = Data()
    
    let progress = BehaviorRelay<Double>(value: 0)
    lazy var timerInterval: Double = {
        if modelName.hasPrefix("iPhone7") {
            return 0.025
        }
        return 0.015
    }()
    var isCancelTask = false
    
    func sendData(index: Int) {
//        guard index < datas.count, !isCancelTask else {return}
        guard let data = self.getSendData(index: index), !isCancelTask else {return}
//        guard self.ble?.peripheral.state == .connected else {
//            return
//        }
        
        self.ble?.sendIfNeed(data)
        
//        self.ble?.sendIfNeed(datas[index])
//        MTLog.debug("app->dev(index: \(index):\(datas[index].toHexString())")
//        MTLog.debug("发送\(index)包中")
        
        var progress = Double((index)*(self.mtu))/Double(self.fileData.count) * 100
        if progress > 100 {
            progress = 100
        }
        progress = max(progress, self.progress.value)
        self.progress.accept(progress)
        
//        DispatchQueue.main.asyncAfter(wallDeadline: .now()+self.timerInterval) {
//            self.sendData(index: index+1)
//        }
        
        Observable.just(0).delay(.milliseconds(Int(self.timerInterval*1000)), scheduler: MainScheduler.asyncInstance).bind {[weak self] _ in
            guard let self = self else {return}
            self.sendData(index: index+1)
        }.disposed(by: self.disposeBag)
    }
    
    func install(fileData: Data, mtu: Int, complete: @escaping () -> Void) {
//        DispatchQueue(label: "ota_encode").async {
//            self.progress.accept(0)
//            self.datas = .init()
//            
//            let size = mtu-4
//            var offset = 0
//            var lastCrc: UInt16 = 0xffff
//            while true {
//                if let data = self.sendFileBodyOutResponseData(data: fileData, size: size, offset: offset, lastCrc: lastCrc) {
//                    self.datas.append(data.0)
//                    
//                    lastCrc = data.1
//                    offset += size
//                }else {
//                    complete()
//                    break
//                }
//            }
//        }
        self.fileData = fileData
        self.mtu = mtu
        complete()
    }
    
    func getSendData(index: Int) -> Data? {
        if index < self.datas.count {
            return self.datas[index]
        }
        let size = mtu-4
        let offset = index*size
        let lastCrc: UInt16 = 0xffff
        
        if let data = self.sendFileBodyOutResponseData(data: fileData, size: size, offset: offset, lastCrc: lastCrc) {
            self.datas.append(data.0)
            return data.0
        }
        return nil
    }
    
    
    func sendFileBodyOutResponseData(data: Data, size: Int, offset: Int, lastCrc: UInt16 = 0xffff) -> (Data, UInt16)? {
        if offset > data.count-1 {return nil}
        
        let end = min(offset+size, data.count)
        var body = data[offset..<end]
        
        var type: TLOCPPayloadType
        if offset == 0 {
            type = .headAndBin
        }else if end == data.count {
            type = .footAndBin
        }else {
            type = .bodyAndBin
        }
        
        var packageNumber = offset/size
        let packageNumberData = NSData(bytes: &packageNumber, length: 4) as Data
        body = packageNumberData + body
        
        let crc = UNIOTABtUtils.watchCrc16Uint(body, result: 0xffff)
        
        let sendData = TLOCPModel.data(scene: 0x0e, command: 0x0003, payLoad: body, type: type, dataOffset: offset, crc16: true, result: 0xffff)
        
        return (sendData, crc)
    }
    
    override func cancel() {
        super.cancel()
        self.datas = .init()
        self.progress.accept(0)
        self.isCancelTask = true
    }
}
