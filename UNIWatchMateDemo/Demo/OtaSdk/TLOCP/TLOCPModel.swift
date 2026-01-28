//
//  TLOCPModel.swift
//  Pods
//
//  Created by t_t on 2023/8/16.
//

import Foundation

public struct TLOCPModel {
    var serialNumber: UInt8
    var type: TLOCPPayloadPageType
    var length: Int
    var payload: Data
    var encodeType: TLOCPPlayLoadEncodeType
    var sceneId: Int
    var commandId: Int
    
    public init?(data: Data) {
        guard data.count >= 16 else {return nil}
        guard let sceneId = data[0...0].toIntLittleEndian() else {return nil}
        guard let commandId = data[2...3].toIntLittleEndian() else {return nil}
        guard let type = TLOCPPayloadPageType(data: data[4]) else {return nil}
        guard let encodeType = TLOCPPlayLoadEncodeType(data: data[4]) else {return nil}
        self.serialNumber = data[1]
        self.sceneId = sceneId
        self.commandId = commandId
        self.type = type
        self.encodeType = encodeType
        let payload: Data
        if data.count > 16 {
            payload = Data(data[16..<data.count])
        }else {
            payload = Data()
        }
        let crclong = UNIOTABtUtils.crcLong(payload)
        if let crc = data[12..<12+4].toIntLittleEndian(), crc != crclong {
            DDLogInfo("crc校验失败, raw: \(data.to2HexString())")
            return nil
        }
        self.payload = payload
        self.length = Int(data[6...7].withUnsafeBytes{$0.load(as: Int16.self)})
    }
    
    static var serialNumber: UInt8 = 0x00
    
    static func pushSerialNumber() -> Data {
        if self.serialNumber+1 > 0xfe {
            self.serialNumber = 0x01
        }else {
            self.serialNumber += 1
        }
        return Data([self.serialNumber])
    }
    
    /// 写入总包大小和分包类型
    /// - Parameters:
    ///   - value: 总包大小
    ///   - divideType: 分包类型+数据类型
    static func writeShortToBytes(_ packageSize: UInt16, withDivideType divideType: UInt8) -> [UInt8] {
        var result: [UInt8] = [0, 0]
        
        // 用第一个字节的高5位存储value的高5位
        result[0] = UInt8((packageSize >> 8) << 3 & 0b11111000)
        
        // 把divideType的低3位写入result[0]的低3位
        result[0] |= (divideType & 0b00000111)
        
        // 用第二个字节存储value的低8位
        result[1] = UInt8(packageSize & 0xFF)
        
        return result
    }
    
    static func readShortFromBytes(_ data: [UInt8]) -> Int16 {
        guard data.count == 2 else {
            fatalError("Invalid byte array length")
        }
        
        // 使用第一个字节的低8位和第二个字节的高5位构造Int16值
        let lowerByte = Int16(data[1])
        let upperByte = Int16(Int16(data[0] & 0b11111000) >> 3) << 8
        return lowerByte | upperByte
    }
    
    static func data(serialNumber: UInt8? = nil, scene: Int, command: Int, payLoad: Data, type: TLOCPPayloadType = .noneAndBin, dataOffset: Int = 0, crc16: Bool = true, result: UInt16 = 0xffff, total: UInt16 = 1) -> Data {
        var count = payLoad.count
        
        let sceneUInt8 = UInt8(scene)
        var commandUInt16 = UInt16(command)
        
        let scene = Data([sceneUInt8])
        let serialNumberData: Data
        if let serialNumber = serialNumber {
            serialNumberData = Data([serialNumber])
        }else {
            serialNumberData = pushSerialNumber()
        }
        let command = Data(bytes: &commandUInt16, count: 2)
        let _type = scene+serialNumberData+command
        
//        let subcontract = Data([type.rawValue])
//        let lengthKeep = Data([0x00])
        let subcontract = writeShortToBytes(total, withDivideType: type.rawValue)
        
        let lengthBody = Data(bytes: &count, count: 2)
        let length = subcontract+lengthBody
        
        var dataOffset = dataOffset
        let offset = Data(bytes: &dataOffset, count: 4)
        
        let crc: Data
        if crc16 {
            crc = UNIOTABtUtils.watchCrc16(payLoad, result: result) as Data //Data(hex: UNIOTABtUtils.crc(payLoad))
        }else {
            crc = Data(hex: UNIOTABtUtils.crc8maxim(payLoad))+Data([UInt8](0..<3).map{_ in 0x00})
        }
        
        let sendData = _type+length+offset+crc+payLoad

        return sendData
    }
}

extension TLOCPModel {
    static func install(scene: Int, command: Int, rawData: Data, mtu: Int, complete: @escaping ([Data]) -> Void) {
        guard mtu > 0 else {
            let data = self.data(scene: scene, command: command, payLoad: rawData)
            complete([data])
            return
        }
        DispatchQueue(label: "tlocp_packaging").async {
            var datas = [Data]()
            
            let size = mtu
            var offset = 0

            let serialNumber = TLOCPModel.pushSerialNumber()
            
            while true {
                if let data = self.sendFileBodyOutResponseData(serialNumber: serialNumber[0], scene: scene, command: command, data: rawData, size: size, offset: offset) {
                    datas.append(data)
                    
                    offset += size
                }else {
                    complete(datas)
                    break
                }
            }
        }
    }
    
    static func sendFileBodyOutResponseData(serialNumber: UInt8, scene: Int, command: Int, data: Data, size: Int, offset: Int) -> Data? {
        if offset > data.count-1 {return nil}
        
        let end = min(offset+size, data.count)
        let body = data[offset..<end]
        
        var type: TLOCPPayloadType
        if offset == 0 && offset+size >= data.count {
            type = .noneAndBin
        }else if offset == 0 {
            type = .headAndBin
        }else if end == data.count {
            type = .footAndBin
        }else {
            type = .bodyAndBin
        }
        
//        var packageNumber = offset/size
//        let packageNumberData = NSData(bytes: &packageNumber, length: 4) as Data
//        body = packageNumberData + body
//        MTLog.debug("payload count: \(body.count)")
//        MTLog.debug("data count: \(data.count)")
        
        let sendData = TLOCPModel.data(serialNumber: serialNumber, scene: scene, command: command, payLoad: body, type: type, dataOffset: offset, crc16: true, total: .init(data.count))
        
        return sendData
    }
}
