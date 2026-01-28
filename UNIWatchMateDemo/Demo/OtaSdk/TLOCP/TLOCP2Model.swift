//
//  TLOCP2Model.swift
//  TLOCP2Decode
//
//  Created by t_t on 2024/1/16.
//

/// TLOCP2 协议模型实现
/// 该文件包含了TLOCP2协议相关的所有数据模型和编解码实现

import Foundation

/// 将短整数和分割类型写入字节数组
/// - Parameters:
///   - packageSize: 包大小
///   - divideType: 分割类型
/// - Returns: 包含编码结果的字节数组
func writeShortToBytes(_ packageSize: UInt16, withDivideType divideType: UInt8) -> [UInt8] {
    var result: [UInt8] = [0, 0]
    
    // 用第一个字节的高5位存储value的高5位
    result[0] = UInt8((packageSize >> 8) << 3 & 0b11111000)
    
    // 把divideType的低3位写入result[0]的低3位
    result[0] |= (divideType & 0b00000111)
    
    // 用第二个字节存储value的低8位
    result[1] = UInt8(packageSize & 0xFF)
    
    return result
}

/// TLOCP2协议类型模型
public struct TLOCP2TypeModel {
    public var sceneId: UInt8      // 场景ID
    public var serialNumber: UInt8  // 序列号
    public var commandId: UInt16    // 命令ID
}

extension TLOCP2TypeModel {
    /// 从数据初始化类型模型
    /// - Parameter data: 输入数据
    init?(data: Data) {
        guard data.count >= 4 else { return nil }
        self.sceneId = data[0]
        self.serialNumber = data[1]
        self.commandId = data[2..<4].data.uint16
    }
    
    /// 将类型模型转换为数据
    var toData: Data {
        var data = Data()
        data.append(sceneId)
        data.append(serialNumber)
        var commandId = commandId
        data.append(Data(bytes: &commandId, count: 2))
        return data
    }
}

/// TLOCP2长度类型枚举
public enum TLOCP2LengthType: UInt8 {
    case none = 0           // 无分包
    case header = 0b00000001  // 分包头部
    case body = 0b00000010    // 分包主体
    case footer = 0b00000011  // 分包尾部
    
    init?(data: UInt8) {
        let maskedValue = data & 0b00000011
        switch maskedValue {
        case 0b00000000: self = .none
        case 0b00000001: self = .header
        case 0b00000010: self = .body
        case 0b00000011: self = .footer
        default: return nil
        }
    }
}

/// TLOCP2编码类型枚举
public enum TLOCP2EncodeType: UInt8 {
    case bin = 0b00000000   // 二进制编码
    case json = 0b00000100  // JSON编码
    
    init?(data: UInt8) {
        let maskedValue = data & 0b00000100
        switch maskedValue {
        case 0b00000000: self = .bin
        case 0b00000100: self = .json
        default: return nil
        }
    }
}

/// TLOCP2长度模型
public struct TLOCP2LengthModel {
    public var type: TLOCP2LengthType          // 长度类型
    public var encodeType: TLOCP2EncodeType    // 编码类型
    public var totalLength: UInt16             // 总长度
    public var payloadLength: UInt16           // 负载长度
}

extension TLOCP2LengthModel {
    init?(data: Data) {
        guard data.count >= 4 else { return nil }
        guard let type = TLOCP2LengthType(data: data[0]),
              let encodeType = TLOCP2EncodeType(data: data[0]) else {
            return nil
        }
        self.type = type
        self.encodeType = encodeType
        self.totalLength = Data([data[1], data[0] >> 3]).uint16
        self.payloadLength = data[2..<4].data.uint16
    }
    
    var toData: Data {
        let type = type.rawValue | encodeType.rawValue
        let subcontract = writeShortToBytes(totalLength, withDivideType: type)
        
        var data = Data()
        data.append(Data(subcontract))
        var payloadLength = payloadLength
        data.append(Data(bytes: &payloadLength, count: 2))
        return data
    }
}

/// TLOCP2负载类型枚举
public enum TLOCP2PayloadType: UInt8 {
    case invalid = 0    // 无效
    case read          // 读取
    case write         // 写入
    case execute       // 执行
    case notify        // 通知
    
    case each = 100    // 每个
    case all_ok        // 全部成功
    case all_fail      // 全部失败
}

/// TLOCP2负载错误枚举
public enum TLOCP2PayloadError: UInt8, Error {
    case ok = 0             // 成功
    case fail              // 失败
    case nodata            // 无数据
    case invalid_param     // 无效参数
    case invalid_urn       // 无效URN
    case invalid_data      // 无效数据
    case invalid_cmd       // 无效命令
    case invalid_package   // 无效包
    case invalid_package_seq  // 无效包序列
    case invalid_package_limit  // 无效包限制
    case invalid_item_count    // 无效项目计数
    case invalid_item_list     // 无效项目列表
    case invalid_item_data     // 无效项目数据
}

/// TLOCP2负载编码类型枚举
public enum TLOCP2PayloadEncodeType: UInt8 {
    case binary = 0    // 二进制
    case plaintext     // 纯文本
    case json         // JSON
    case nodata       // 无数据
    case errcode      // 错误码
}

/// TLOCP2负载项目模型
public struct TLOCP2PayloadItemModel {
    public var urn: String                     // URN标识符
    public var data_fmt: TLOCP2PayloadEncodeType  // 数据格式
    public var data_len: UInt16                   // 数据长度
    public var data: Data                         // 数据内容
    public var nextItemData: Data?                // 下一个项目的数据
    public var error: TLOCP2PayloadError?         // 错误信息
}

extension TLOCP2PayloadItemModel {
    init?(data: Data) {
        // 1. 检查最小数据长度要求 (URN[4] + fmt[1] + len[2] = 7)
        guard data.count >= 7 else { return nil }
        
        // 2. 安全获取URN
        guard let urn = data[0..<4].data.toString(encoding: .ascii),
              !urn.isEmpty else { return nil }
        self.urn = urn
        
        // 3. 安全获取数据格式
        guard let data_fmt = TLOCP2PayloadEncodeType(rawValue: data[4]) else { return nil }
        self.data_fmt = data_fmt
        
        // 4. 获取数据长度
        self.data_len = data[5..<7].data.uint16
        
        // 5. 安全获取数据内容
        if data_len == 0 {
            self.data = Data()
        } else {
            guard data.count >= 7 + Int(data_len) else { return nil }
            self.data = data[7..<7+Int(data_len)].data
        }
        
        // 6. 处理错误码
        if data_fmt == .errcode, self.data.count == 1 {
            self.error = TLOCP2PayloadError(rawValue: self.data[0])
        }
        
        // 7. 处理下一个项目数据
        if data.count > 7 + Int(data_len) {
            self.nextItemData = Data(data[7+Int(data_len)..<data.count])
        } else {
            self.nextItemData = nil
        }
    }
    
    var toData: Data {
        var data = Data()
        // 确保URN数据可以被编码
        guard let urnData = self.urn.data(using: .ascii) else {
            return Data()
        }
        data.append(urnData)
        data.append(Data([self.data_fmt.rawValue]))
        var data_len = self.data_len
        data.append(Data(bytes: &data_len, count: 2))
        data.append(self.data)
        return data
    }
}

/// TLOCP2负载模型
public struct TLOCP2PayloadModel {
    public var request_id: UInt16     // 请求ID
    public var package_seq: UInt32    // 包序列号
    public var type: TLOCP2PayloadType  // 负载类型
    public var package_limit: UInt16    // 包限制
    public var item_count: UInt8        // 项目数量
    public var items: [TLOCP2PayloadItemModel]  // 项目列表
}

extension TLOCP2PayloadModel {
    public init?(data: Data) {
        // 1. 检查最小数据长度要求
        guard data.count >= 10 else { return nil }
        
        // 2. 安全解析负载类型
        guard let type = TLOCP2PayloadType(rawValue: data[6]) else { return nil }
        
        self.request_id = data[0..<2].data.uint16
        self.package_seq = data[2..<6].data.uint32
        self.type = type
        self.package_limit = data[7..<9].data.uint16
        self.item_count = data[9]
        
        // 3. 安全解析项目列表
        var items = [TLOCP2PayloadItemModel]()
        var nextItemData = data[10..<data.count].data
        
        // 4. 防止无限循环
        let maxItems = min(Int(self.item_count), 255)  // 限制最大项目数
        for _ in 0..<maxItems {
            guard let item = TLOCP2PayloadItemModel(data: nextItemData) else { break }
            items.append(item)
            guard let nextData = item.nextItemData else { break }
            nextItemData = nextData
        }
        
        self.items = items
    }
    
    var toData: Data {
        var data = Data()
        var request_id = request_id
        data.append(Data(bytes: &request_id, count: 2))
        var package_seq = package_seq
        data.append(Data(bytes: &package_seq, count: 4))
        data.append(type.rawValue.data)
        var package_limit = package_limit
        data.append(Data(bytes: &package_limit, count: 2))
        data.append(item_count.data)
        
        // 安全添加项目数据
        for item in items {
            data.append(item.toData)
        }
        return data
    }
}

/// TLOCP2主模型
public struct TLOCP2Model {
    public var typeModel: TLOCP2TypeModel        // 类型模型
    public var lengthModel: TLOCP2LengthModel    // 长度模型
    public var offset: UInt32                    // 偏移量
    public var crc: String                       // CRC校验和（十六进制字符串）
    public var crcData: Data                     // CRC原始数据
    public var payloadModel: TLOCP2PayloadModel? // 负载模型
    public var payloadData: Data?                // 负载数据
    public var packageNumber: Int = 0            // 包序号
    
    /// 单次编码
    public static func encodeOnce(sceneId: UInt8, commandId: UInt16, offset: Int, payload: Data,
                                lengthType: TLOCP2LengthType, encodeType: TLOCP2EncodeType = .bin) -> TLOCP2Model {
        // 计算CRC
        let crc = UNIOTABtUtils.watchCrc16(payload, result: 0xffff) as Data
        
        // 创建模型
        let model = TLOCP2Model(
            typeModel: .init(sceneId: sceneId, serialNumber: serialNumber, commandId: commandId),
            lengthModel: .init(type: lengthType, encodeType: encodeType,
                             totalLength: UInt16(payload.count), payloadLength: UInt16(payload.count)),
            offset: UInt32(offset),
            crc: crc.toHexString(),
            crcData: crc,
            payloadModel: nil,
            payloadData: payload
        )
        return model
    }
    
    /// 编码数据
    public static func encode(sceneId: UInt8, commandId: UInt16, payload: Data,
                            encodeType: TLOCP2EncodeType = .bin, mtu: Int = .max) -> [TLOCP2Model] {
        // 参数验证
        guard mtu >= 16 else { return [] }  // MTU必须至少能容纳头部
        
        var models = [TLOCP2Model]()
        var startIndex = 0
        let serialNumber = pushSerialNumber()
        
        // 处理空负载的情况
        if payload.count == 0 {
            let crc = UNIOTABtUtils.watchCrc16(.init(), result: 0xffff) as Data
            let model = TLOCP2Model(
                typeModel: .init(sceneId: sceneId, serialNumber: serialNumber, commandId: commandId),
                lengthModel: .init(type: .none, encodeType: encodeType, totalLength: 0, payloadLength: 0),
                offset: 0,
                crc: crc.toHexString(),
                crcData: crc,
                payloadModel: nil,
                payloadData: .init()
            )
            return [model]
        }
        
        // 分包处理
        while startIndex < payload.count {
            let remainingBytes = payload.count - startIndex
            let payloadLength = min(remainingBytes, mtu)
            let payloadData = Data(payload[startIndex..<startIndex+payloadLength])
            
            // 确定长度类型
            let lengthType: TLOCP2LengthType
            if payloadLength == payload.count {
                lengthType = .none
            } else if startIndex == 0 {
                lengthType = .header
            } else if startIndex + payloadLength == payload.count {
                lengthType = .footer
            } else {
                lengthType = .body
            }
            
            // 计算CRC
            let crc = UNIOTABtUtils.watchCrc16(payloadData, result: 0xffff) as Data
            
            // 创建模型
            let model = TLOCP2Model(
                typeModel: .init(sceneId: sceneId, serialNumber: serialNumber, commandId: commandId),
                lengthModel: .init(type: lengthType, encodeType: encodeType,
                                 totalLength: UInt16(payload.count), payloadLength: UInt16(payloadData.count)),
                offset: UInt32(startIndex),
                crc: crc.toHexString(),
                crcData: crc,
                payloadModel: .init(data: payloadData),
                payloadData: payloadData
            )
            
            models.append(model)
            startIndex += payloadLength
        }
        
        return models
    }
    
    /// 使用URN编码数据
    public static func encode(sceneId: UInt8, commandId: UInt16, urn: String, data: Data,
                            payloadType: TLOCP2PayloadType, data_fmt: TLOCP2PayloadEncodeType,
                            encodeType: TLOCP2EncodeType = .bin, mtu: Int = .max) -> [TLOCP2Model] {
        // 1. 参数验证
        guard !urn.isEmpty,
              urn.count <= 4,     // URN长度限制
              mtu >= 16,          // 最小MTU限制
              data.count <= UInt16.max - 7  // 数据长度限制（考虑头部空间）
        else { return [] }
        
        // 2. 创建项目模型
        let dataLen = UInt16(data.count)
        let itemModel = TLOCP2PayloadItemModel(
            urn: urn,
            data_fmt: data_fmt,
            data_len: dataLen,
            data: data
        )
        
        // 3. 创建负载模型
        let payloadModel = TLOCP2PayloadModel(
            request_id: pushRequestId(),
            package_seq: .max,
            type: payloadType,
            package_limit: 0,
            item_count: 1,
            items: [itemModel]
        )
        
        let payload = payloadModel.toData
        
        // 4. 验证生成的payload大小
        guard payload.count <= UInt16.max else { return [] }
        
        // 5. 处理单包情况
        if mtu == .max {
            let crc = UNIOTABtUtils.watchCrc16(payload, result: 0xffff) as Data
            let model = TLOCP2Model(
                typeModel: .init(sceneId: sceneId, serialNumber: pushSerialNumber(), commandId: commandId),
                lengthModel: .init(type: .none, encodeType: encodeType,
                                 totalLength: UInt16(payload.count), payloadLength: UInt16(payload.count)),
                offset: 0,
                crc: crc.toHexString(),
                crcData: crc,
                payloadModel: payloadModel,
                payloadData: payload
            )
            return [model]
        }
        
        // 6. 处理分包情况
        return encode(
            sceneId: sceneId,
            commandId: commandId,
            payload: payload,
            encodeType: encodeType,
            mtu: max(16, min(mtu, Int(UInt16.max)))
        )
    }
    
    /// 将模型转换为数据
    public var toData: Data {
        var data = Data()
        data.append(typeModel.toData)
        data.append(lengthModel.toData)
        var offset = offset
        data.append(Data(bytes: &offset, count: 4))
        data.append(crcData)
        
        if let payloadData = payloadData {
            data.append(payloadData)
        } else if let payloadModel = payloadModel {
            data.append(payloadModel.toData)
        }
        return data
    }
}

// MARK: - Static Properties and Methods
extension TLOCP2Model {
    static var serialNumber: UInt8 = 0x00
    static var requestId: UInt16 = 0x00
    
    /// 生成序列号（1-15循环）
    static func pushSerialNumber() -> UInt8 {
        serialNumber = ((serialNumber + 1) % 15) + 1
        return serialNumber
    }
    
    /// 生成请求ID（1-65535循环）
    static func pushRequestId() -> UInt16 {
        if requestId >= UInt16.max {
            requestId = 1
        } else {
            requestId += 1
        }
        return requestId
    }
    
    /// 从数据初始化模型
    public init?(data: Data) {
        // 1. 检查最小数据长度要求
        guard data.count >= 16 else { return nil }
        
        // 2. 解析类型模型
        let typeData = data[0..<4].data
        guard let typeModel = TLOCP2TypeModel(data: typeData) else { return nil }
        self.typeModel = typeModel
        
        // 3. 解析长度模型
        let lengthData = data[4..<8].data
        guard let lengthModel = TLOCP2LengthModel(data: lengthData) else { return nil }
        self.lengthModel = lengthModel
        
        // 4. 验证长度合法性
        if lengthModel.totalLength > UInt16.max || lengthModel.payloadLength > lengthModel.totalLength {
            MTLog.info("[TLOCP Error] Invalid lengths - total: \(lengthModel.totalLength), payload: \(lengthModel.payloadLength)")
//            return nil
        }
        
        // 5. 解析offset和CRC
        self.offset = data[8..<12].data.uint32
        self.crc = data[12..<16].data.toHexString()
        self.crcData = Data(data[12..<16])
        
        // 6. 处理payload数据
        if data.count > 16 {
            let payloadData = data[16..<data.count].data
            
            // 验证payload长度
            guard payloadData.count == lengthModel.payloadLength else {
                MTLog.error("[TLOCP Error] Payload length mismatch - expected: \(lengthModel.payloadLength), actual: \(payloadData.count)")
                return nil
            }
            
            // 验证CRC
            let calculatedCrc = UNIOTABtUtils.watchCrc16(payloadData, result: 0xffff)
            guard calculatedCrc == self.crcData else {
                MTLog.error("[TLOCP Error] CRC mismatch")
                return nil
            }
            
            self.payloadModel = TLOCP2PayloadModel(data: payloadData)
            self.payloadData = payloadData
        } else {
            MTLog.error("[TLOCP Error] data.count < = 16 data = \(data.toHexString())")
            self.payloadModel = nil
            self.payloadData = nil
        }
    }
}
