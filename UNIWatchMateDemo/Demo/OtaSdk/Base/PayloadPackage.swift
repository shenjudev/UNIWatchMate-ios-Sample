//
//  PayloadPackage.swift
//  CameraCapture
//
//  Created by wangwenfeng on 2023/9/26.
//

import Foundation

class RequestIdGenerator {
    static let shared = RequestIdGenerator()
    private static var _currentRequestId: UInt16 = 0
    private init() {}

    func generateRequestId() -> UInt16 {
        Self._currentRequestId += 1
        if Self._currentRequestId == UInt16.max {
            Self._currentRequestId = 0
        }
        return Self._currentRequestId
    }
}
 
enum PackageType: UInt8 {
    case read = 1
    case write
    case execute
    case notify
    
    case each = 100
    case all_ok
    case all_fail
    
    var desc: String {
        switch self {
        case .read:
            return "read"
        case .write:
            return "write"
        case .execute:
            return "execute"
        case .notify:
            return "notify"
        case .each:
            return "each"
        case .all_ok:
            return "all_ok"
        case .all_fail:
            return "all_fail"
        }
    }
}

enum DataFormat: UInt8 {
    case bin = 0
    case txt
    case json
    case nodata
    case errcode
}

struct ItemData {
    let data_fmt: DataFormat
    var data_len: UInt16{UInt16(self.data.count)}
    let data: Data
}

struct ItemNodeData {
    let urn: [UInt8]
    let item: ItemData?
}

struct PayloadPackageHeader {
    let request_type: PackageType
    let package_limit: UInt16
    let item_count: UInt8
}

struct PayloadPackage {
    let request_id: UInt16
    let package_seq: UInt32
    let header: PayloadPackageHeader?
    let items_data: [ItemNodeData]
}

enum TLOCP2ErrorType: UInt8, Error {
    case OK = 0
    case FAIL
    case NODATA
    case INVALID_PARAM
    case INVALID_URN
    case INVALID_DATA
    case INVALID_CMD
    case INVALID_PACKAGE
    case INVALID_PACKAGE_SEQ
    case INVALID_PACKAGE_LIMIT
    case INVALID_ITEM_COUNT
    case INVALID_ITEM_LIST
    case INVALID_ITEM_DATA
    case INVALID_ITEM_DATA_LEN
    case INVALID_ITEM_DATA_FMT
    case INVALID_ITEM_DATA_URN
}

struct TLOCP2PackageItemModel {
    var urnString: String
    var urnData: Data?
    var error: TLOCP2ErrorType?
}

struct TLOCP2PackageModel {
    var type: PackageType
    var items: [TLOCP2PackageItemModel]
    var emptyData: Bool {
        return items.reduce(Data(), {$0 + ($1.urnData ?? Data())}).count == 0
    }
}

struct TLOCP2ResponseModel {
    var id: UInt16
    var index: UInt32
    var data: Data
}

extension PayloadPackage {
    
    static func requestId() -> UInt16 {
        return RequestIdGenerator.shared.generateRequestId()
    }
    
    static func packageItemsData(rawData: Data, mtu: Int = 0) -> [Data] {
        var tureMtu = mtu
        if mtu == 0 {
            tureMtu = rawData.count
        }
        
        var offset = 0
        var packageItemsData = [Data]()
        while offset < rawData.count {
            let end = min(offset+tureMtu, rawData.count-1)
            
            let data: Data
            if offset == end {
                data = Data([rawData[offset]])
            }else {
                data = Data(rawData[offset...end])
            }
            packageItemsData.append(data)
            offset += tureMtu
        }
        return packageItemsData
    }
    
    static func packageDataFrom(id: UInt16, rawDatas: [Data], index: UInt32 = .max, type: PackageType, mtu: Int = 0, urn:[UInt8], data_fmt: DataFormat? = nil) -> [Data] {
        
        var response_id = id
        let response_id_data = Data(bytes: &response_id, count: 2)
        
        var response_type = type.rawValue
        let response_type_data = Data(bytes: &response_type, count: 1)
        
        var package_limit = mtu
        let package_limit_data = Data(bytes: &package_limit, count: 2)
        
        let urn_data = Data(urn)
        
        var package_seq = index
        let package_seq_data = Data(bytes: &package_seq, count: 4)
        
        guard let data_fmt = data_fmt, let rawData = rawDatas.first else {
            var packageData = Data()
            packageData.append(response_id_data)
            packageData.append(package_seq_data) //package_seq
            packageData.append(response_type_data)
            packageData.append(package_limit_data)
            packageData.append(Data([0x01])) //item_count 一个节点
            packageData.append(urn_data)
            packageData.append(Data([0x00, 0x00, 0x00]))
            return [packageData]
        }
        
        var packageData = Data()
        packageData.append(response_id_data)
        packageData.append(package_seq_data) //package_seq
        packageData.append(response_type_data)
        packageData.append(package_limit_data)
        packageData.append(Data([0x01])) //item_count 一个节点
        packageData.append(urn_data)

        var _data_fmt = data_fmt.rawValue
        let data_fmt_data = Data(bytes: &_data_fmt, count: 1)
        packageData.append(data_fmt_data)

        var data_len = rawData.count
        let data_len_data = Data(bytes: &data_len, count: 2)
        packageData.append(data_len_data)

        packageData.append(rawData)

        return [packageData]
    }
    
    static func tlopcDataFrom(id: UInt16, rawDatas: [Data], type: PackageType, command: Int, mtu: Int = 0, urn:[UInt8], data_fmt: DataFormat? = nil, complete: @escaping ([Data]) -> Void) {
        let rawData = self.packageDataFrom(id:id, rawDatas: rawDatas, type: type, mtu: mtu, urn: urn, data_fmt: data_fmt)[0]

        TLOCPModel.install(scene: 0x30, command: command, rawData: rawData, mtu: mtu, complete: complete)
    }
    
    static func tlocpPackaging(rawDatas: [Data], index: Int, command: Int, mtu: Int, complete: @escaping ([Data]) -> Void) {
        guard index < rawDatas.count else {return}
        let rawData = rawDatas[index]
        
        var rsData = [Data]()
        TLOCPModel.install(scene: 0x30, command: command, rawData: rawData, mtu: mtu) { data in
            rsData.append(contentsOf: data)
            
        }
    }
    
    static func tlopcDataRequestFrom(id: UInt16, rawDatas: [Data], type: PackageType, mtu: Int = 0, urn:[UInt8], data_fmt: DataFormat? = nil) -> [Data] {
        let packages = self.packageDataFrom(id:id, rawDatas: rawDatas, type: type, mtu: mtu, urn: urn, data_fmt: data_fmt)
        var tlocpDatas = [Data]()
        
        var count = 0
        
        for package in packages {
            if package == packages.first {
                count += package.count
            }else {
                count += package.count-10
            }
        }
        
        for package in packages {
            if package == packages.first && package == packages.last {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0001, payLoad: package, type: .noneAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else if package == packages.first {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0001, payLoad: package, type: .headAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else if package == packages.last {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0001, payLoad: package, type: .footAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0001, payLoad: package, type: .bodyAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }
        }
        
        return tlocpDatas
    }
    
    static func tlopcDataResponseFrom(id: UInt16, rawDatas: [Data], type: PackageType, mtu: Int = 0, urn:[UInt8], data_fmt: DataFormat? = nil) -> [Data] {
        let packages = self.packageDataFrom(id:id, rawDatas: rawDatas, type: type, mtu: mtu, urn: urn, data_fmt: data_fmt)
        var tlocpDatas = [Data]()
        
        var count = 0
        
        for package in packages {
            if package == packages.first {
                count += package.count
            }else {
                count += package.count-10
            }
        }
        
        for package in packages {
            if package == packages.first && package == packages.last {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0002, payLoad: package, type: .noneAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else if package == packages.first {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0002, payLoad: package, type: .headAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else if package == packages.last {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0002, payLoad: package, type: .footAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }else {
                let data = TLOCPModel.data(scene: 0x30, command: 0x0002, payLoad: package, type: .bodyAndBin, total: UInt16(count))
                tlocpDatas.append(data)
            }
        }
        
        return tlocpDatas
    }
}

extension PayloadPackage {
    static func decoder(payload: Data) -> TLOCP2ResponseModel? {
        guard payload.count > 2,
              let id = payload[0..<2].toIntLittleEndian(),
              payload.count > 6,
              let index = payload[2..<6].toIntLittleEndian()
        else {return nil}
        
        let data = payload[6..<payload.count]
        return .init(id: UInt16(id), index: UInt32(index), data: data)
    }
    
    static func decoder(rawData: Data) -> TLOCP2PackageModel? {
        guard rawData.count > 1,
              let type = PackageType(rawValue: rawData[0])
        else {return nil}

        
        if type == .all_fail || type == .all_ok {
            return .init(type: type, items: [])
        }
        
        var items = [TLOCP2PackageItemModel]()
        var offset = 4
        
        while offset < rawData.count {
            guard offset + 4 < rawData.count+1,
                  let urnString = String(data: Data(rawData[offset..<offset+4]), encoding: .ascii)
            else {break}
            offset += 4
            
            guard offset + 1 < rawData.count+1,
                  let fmt = DataFormat(rawValue: rawData[offset])
            else {break}
            offset += 1
            
            guard offset + 2 < rawData.count+1,
                  let lenght = rawData[offset..<offset+2].toIntLittleEndian()
            else {break}
            offset += 2
            
            // error
            if fmt == .errcode {
                guard offset + 1 < rawData.count+1,
                      let error = TLOCP2ErrorType(rawValue: rawData[offset])
                else {break}
                items.append(.init(urnString: urnString, urnData: nil, error: error))
                offset += 1
                continue
            }
            
            guard offset + lenght < rawData.count+1 else {break}
            let data = Data(rawData[offset..<offset+lenght])
            items.append(.init(urnString: urnString, urnData: data, error: nil))
            offset += lenght
            
            guard rawData.count > offset,
                  let type = PackageType(rawValue: rawData[offset])
            else {break}
            if type == .all_fail || type == .all_ok { break }
            
            offset += 4
        }
        
        return .init(type: type, items: items)
    }
}

//enum RequestType: UInt8 {
//    case REQ_TYPE_READ = 0
//    case REQ_TYPE_WRITE
//    case REQ_TYPE_EXECUTE
//    // other REQUEST TYPE ...
//
//    case RESP_TYPE_EACH = 100
//    case RESP_TYPE_ALL_OK
//    case RESP_TYPE_ALL_FAIL
//    // other RESPONSE TYPE ...
//}
//

//
//enum DataFormat: Int {
//    case FMT_BIN
//    case FMT_PLAIN_TXT
//    case FMT_JSON
//    case FMT_NODATA
//    case FMT_ERRCODE
//}
//
//extension Data {
//    mutating func extractByte() -> UInt8 {
//        return self.popFirst() ?? 0
//    }
//
//    mutating func extractShort() -> Int16 {
//        let value = self.prefix(2).withUnsafeBytes { $0.load(as: Int16.self) }
//        self.removeFirst(2)
//        return value
//    }
//
//    mutating func extractInt() -> Int {
//        let value = self.prefix(4).withUnsafeBytes { $0.load(as: Int32.self) }
//        self.removeFirst(4)
//        return Int(value)
//    }
//
//    mutating func extractUInt() -> UInt32 {
//        let value = self.prefix(4).withUnsafeBytes { $0.load(as: UInt32.self) }
//        self.removeFirst(4)
//        return UInt32(value)
//    }
//}
//
//extension Int16 {
//    var data: Data {
//        var int = self
//        return Data(bytes: &int, count: MemoryLayout.size(ofValue: self))
//    }
//}
//
//extension Int32 {
//    var data: Data {
//        var int = self
//        return Data(bytes: &int, count: MemoryLayout.size(ofValue: self))
//    }
//}
//
//extension UInt32 {
//    var data: Data {
//        var uint = self
//        return Data(bytes: &uint, count: MemoryLayout.size(ofValue: self))
//    }
//}
//
//struct NodeData: CustomStringConvertible {
//    var urn: Data
//    var data: Data
//    var dataFmt: DataFormat
//    var dataLen: Int16
//
//    init(urn: Data = Data(), data: Data = Data(), dataFmt: DataFormat = .FMT_BIN) {
//        self.urn = urn
//        self.data = data
//        self.dataFmt = dataFmt
//        self.dataLen = Int16(self.data.count)
//    }
//
//    var description: String {
//        return "NodeData(urn=\(urn), dataFmt=\(dataFmt), dataLen=\(dataLen), data=\(data))"
//    }
//
//    func toBytes(requestType: UInt8) -> Data {
//        var bytes = Data()
//        bytes.append(urn)
//        if requestType != RequestType.REQ_TYPE_READ.rawValue {
//            bytes.append(UInt8(dataFmt.rawValue))
//            bytes.append(contentsOf: withUnsafeBytes(of: dataLen.bigEndian) { Data($0) })
//            bytes.append(data)
//        }
//
//
//        return bytes
//    }
//
//    static func fromByteBuffer(bytes: inout Data, type: UInt8) -> NodeData {
//        var nodeData = NodeData()
//
//        // Extracting urn
//        let urnRange = bytes.startIndex..<bytes.startIndex.advanced(by: 4)
//        nodeData.urn = bytes.subdata(in: urnRange)
//        bytes.removeSubrange(urnRange) // This simulates the movement of ByteBuffer's position in Kotlin
//
//        if type != RequestType.REQ_TYPE_READ.rawValue {
//            // Extracting data format
//            nodeData.dataFmt = DataFormat(rawValue: Int(bytes.extractByte())) ?? .FMT_BIN // Assuming a default value here
//            nodeData.dataLen = bytes.extractShort()
//
//            // Extracting data
//            let dataRange = bytes.startIndex..<bytes.startIndex.advanced(by: Int(nodeData.dataLen))
//            nodeData.data = bytes.subdata(in: dataRange)
//            bytes.removeSubrange(dataRange)
//        }
//
//
//        return nodeData
//    }
//
//}
//
///// 树形payload, 可以实现数据转为字节流；‘或把字节流转为Payload对象
//class PayloadPackage {
//    var _id: Int16
//    var packageSeq: UInt32
//    // 请求或响应的类型
//    var actionType: UInt8
//    //
//    var packageLimit: Int16
//    // 本包的节点个数
//    var itemCount: Int
//    // 节点数组
//    var itemList: [NodeData]
//
//    init(packageSeq: UInt32, actionType: RequestType, packageLimit: Int16, itemCount: Int, itemList: [NodeData]) {
//        _id = RequestIdGenerator.shared.generateRequestId()
//        self.packageSeq = packageSeq
//        self.actionType = actionType.rawValue
//        self.packageLimit = packageLimit
//        self.itemCount = itemCount
//        self.itemList = itemList
//    }
//
//
//    /// 从字节数组中解析出"首包"PayloadPackage
//    /// - Parameter payloadData: 字节流
//    /// - Returns: payload对象
//    static func fromByteArray(payloadData: Data) -> PayloadPackage {
//        var bytes = payloadData
//
//        let actionType = bytes.extractByte()
//        var itemList = [NodeData]()
//
//        while !bytes.isEmpty {
//            let nextNode = NodeData.fromByteBuffer(bytes:&bytes, type:actionType)
//            itemList.append(nextNode)
//        }
//
//        let payload = PayloadPackage(packageSeq: bytes.extractUInt(),
//                                     actionType: .init(rawValue: actionType)!,
//                                     packageLimit: bytes.extractShort(),
//                                     itemCount: Int(bytes.extractByte()),
//                                     itemList: itemList)
//
//        if (payload.itemList.count != payload.itemCount) {
//            fatalError("itemList.size != itemCount")
//        }
//
//        return payload
//    }
//
//    private func buildPackageHeader(bytes: inout Data) {
//        bytes.append(_id.data)
//        bytes.append(UInt32(packageSeq).data)
//        packageSeq += 1
//
//        bytes.append(UInt8(actionType))
//        bytes.append(packageLimit.data)
//
//    }
//
//
//    /// 是否还有下一个分包
//    /// - Returns:
//    func hasNext() -> Bool {
//        return packageSeq != 0xFFFFFFFF
//    }
//
//
//    /// 从字节流中解析出"非首包"PayloadPackage
//    /// - Parameter data: 字节流
//    func next(data: Data) {
//        var bytes = data
//
//        _id = bytes.extractShort()
//        packageSeq = bytes.extractUInt()
//        actionType = bytes.extractByte()
//        packageLimit = bytes.extractShort()
//        let count = bytes.extractByte()
//        itemCount += Int(count)
//
//        while !bytes.isEmpty {
//            let nextNode = NodeData.fromByteBuffer(bytes:&bytes, type:actionType)
//            itemList.append(nextNode)
//        }
//        if (itemList.count != itemCount) {
//            fatalError("itemList.size != itemCount")
//        }
//
//    }
//
//
//    /// 添加数据
//    /// - Parameters:
//    ///   - urn: 资源名
//    ///   - data: 数据
//    ///   - dataFmt: 数据类型
//    func putData(urn: Data, data: Data, dataFmt: DataFormat = .FMT_BIN) {
//        let nodeData = NodeData(urn: urn, data: data, dataFmt: dataFmt)
//        itemList.append(nodeData)
//        itemCount += 1
//    }
//
//
//
//    /// 将payload转换为byte数组
//    /// - Parameter mtu: 最小传输单元
//    /// - Returns: payload所有的分包
//    func toByteArray(mtu: Int = 600) -> [Data] {
//        let limitation = mtu
//        var payloadList: [Data] = []
//        var bytes = Data(capacity: limitation)
//
//        var tempByteArray = Data()
//        buildPackageHeader(bytes: &bytes)
//
//        var totalItemCount = 0
//        var count = 0
//
//        for item in itemList {
//            let nextNode = item.toBytes(requestType:actionType)
//            count += 1
//            totalItemCount += 1
//
//            if bytes.count + tempByteArray.count + nextNode.count > limitation {
//                bytes.append(UInt8(count))
//                bytes.append(tempByteArray)
//
//                payloadList.append(bytes)
//
//                count = 0
//                bytes.removeAll()
//                tempByteArray.removeAll()
//                buildPackageHeader(bytes: &bytes)
//            } else {
//                tempByteArray.append(nextNode)
//            }
//        }
//
//        if bytes.count > 0 {
//            var maxValue: UInt32 = 0xFFFFFFFF
//            bytes.replaceSubrange(2..<6, with: Data(bytes: &maxValue, count: 4))
//        }
//        bytes.append(UInt8(count))
//        bytes.append(tempByteArray)
//        payloadList.append(bytes)
//
//        return payloadList
//    }
//
//}
//
//extension PayloadPackage {
//    var description: String {
//        return "PayloadPackage(cmdId=\(_id), packageSeq=\(packageSeq), type=\(actionType), packageLimit=\(packageLimit), itemCount=\(itemCount), itemList=\(itemList))"
//    }
//}
