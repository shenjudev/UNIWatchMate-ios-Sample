//
//  Data+Core.swift
//  TLOCPDecode
//
//  Created by t_t on 2024/1/16.
//

import Foundation
import CoreBluetooth
import AudioToolbox

extension CBManagerState {
    public var desc: String {
        switch self {
        case .unknown: return "未知的"
        case .resetting: return "重置中"
        case .unsupported: return "不支持的"
        case .unauthorized: return "未经授权的"
        case .poweredOff: return "蓝牙已关闭"
        case .poweredOn: return "蓝牙已打开"
        default: return "未知的"
        }
    }
}


extension Date {
    var toString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}

extension String{
    func toMacAddress()->String{
        var macAddress = self
        if macAddress.count >= 12{
            macAddress = String(macAddress[macAddress.startIndex...macAddress.index(macAddress.startIndex, offsetBy: 11)])
            macAddress.insert(":", at: macAddress.index(macAddress.startIndex, offsetBy: 2))
            macAddress.insert(":", at: macAddress.index(macAddress.startIndex, offsetBy: 5))
            macAddress.insert(":", at: macAddress.index(macAddress.startIndex, offsetBy: 8))
            macAddress.insert(":", at: macAddress.index(macAddress.startIndex, offsetBy: 11))
            macAddress.insert(":", at: macAddress.index(macAddress.startIndex, offsetBy: 14))
            let arr =  macAddress.components(separatedBy: ":")
            macAddress = ""
            for str in arr{
                macAddress = macAddress + str + ":"
            }
            macAddress = String(macAddress[macAddress.startIndex...macAddress.index(macAddress.endIndex, offsetBy: -2)])
            
        }
        return macAddress
    }
}

extension Dictionary<String, Any> {
    var manufacturerData: Data? {
        return self["kCBAdvDataManufacturerData"] as? Data
    }
    var localName: String? {
        return self["kCBAdvDataLocalName"] as? String
    }
    var macAddress: String? {
        guard let data = manufacturerData, data.count >= 8 else {return nil}
        guard (data[0] == 0xa0 || data[0] == 0xc0), data[1] == 0x01 else {return nil}
        return data[2..<8].toHexString().toMacAddress()
    }
}

extension Data {
    var uint8: UInt8 { return self[0] }
    var uint16: UInt16 { return self.withUnsafeBytes { $0.load(as: UInt16.self) } }
    var uint32: UInt32 { return self.withUnsafeBytes { $0.load(as: UInt32.self) } }
    var uint64: UInt64 { return self.withUnsafeBytes { $0.load(as: UInt64.self) } }
    
     var data: Data {
        return Data(self)
    }
}

extension Array where Element == UInt8 {
    fileprivate var data: Data {
        return Data(self)
    }
    
    var uint8: UInt8 { return self[0] }
    var uint16: UInt16 { return self.withUnsafeBytes { $0.load(as: UInt16.self) } }
    var uint32: UInt32 { return self.withUnsafeBytes { $0.load(as: UInt32.self) } }
    var uint64: UInt64 { return self.withUnsafeBytes { $0.load(as: UInt64.self) } }
}

extension Data {
    /// 将 Data 转换为十六进制字符串
    func to2HexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// 将十六进制字符串转换为 Data
    init(hex2: String) {
        let trimmedString = hex2.trimmingCharacters(in: .whitespacesAndNewlines)

        // 检查字符串是否以 "0x" 开头
        var startIndex = trimmedString.startIndex
        if trimmedString.hasPrefix("0x") {
            startIndex = trimmedString.index(startIndex, offsetBy: 2)
        }

        // 检查字符串长度是否为偶数
        guard trimmedString[startIndex...].count % 2 == 0 else {
            self = Data()
            return
        }

        var data = Data()
        var index = startIndex

        while index < trimmedString.endIndex {
            let nextIndex = trimmedString.index(index, offsetBy: 2)
            let byteString = trimmedString[index..<nextIndex]

            guard let byte = UInt8(byteString, radix: 16) else {
                self = Data()
                return
            }

            data.append(byte)
            index = nextIndex
        }

        self = data
    }
    
    // 将 Data 转换为 Int
    func toIntLittleEndian() -> Int? {
        guard self.count <= MemoryLayout<Int>.size else {
            return nil
        }

        let totalBytes = MemoryLayout<Int>.size
        var dataToLoad = self

        if self.count < totalBytes {
            let padding = Data(repeating: 0, count: totalBytes - self.count)
            dataToLoad.append(padding)
        }

        return dataToLoad.withUnsafeBytes { $0.load(as: Int.self) }
    }
}

extension Array {
    init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        return self[self.startIndex ..< self.endIndex]
    }
}

extension Array where Element == UInt8 {
    func to2HexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
//    init(hex: String) {
//        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
//        var buffer: UInt8?
//        var skip = hex.hasPrefix("0x") ? 2 : 0
//        for char in hex.unicodeScalars.lazy {
//            guard skip == 0 else {
//                skip -= 1
//                continue
//            }
//            guard char.value >= 48 && char.value <= 102 else {
//                removeAll()
//                return
//            }
//            let v: UInt8
//            let c: UInt8 = UInt8(char.value)
//            switch c {
//            case let c where c <= 57:
//                v = c - 48
//            case let c where c >= 65 && c <= 70:
//                v = c - 55
//            case let c where c >= 97:
//                v = c - 87
//            default:
//                removeAll()
//                return
//            }
//            if let b = buffer {
//                append(b << 4 | v)
//                buffer = nil
//            } else {
//                buffer = v
//            }
//        }
//        if let b = buffer {
//            append(b)
//        }
//    }
}

extension Data {
    static func random(count: Int) -> Data{
        var bytes = [UInt8]()
        for _ in 0..<count {
            bytes.append(.random(in: 0x0...0xff))
        }
        return Data(bytes)
    }
    
    func fillData(count: Int) -> Data {
        var data = Data(count: count)
        data.replaceSubrange(0..<Swift.min(count, self.count), with: self.prefix(count))
        return data
    }
    
    func toString(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)?.replacingOccurrences(of: "\0", with: "")
    }
}

extension Array where Element == UInt8 {
    func toString(encoding: String.Encoding) -> String? {
        let data = Data(self)
        return String(data: data, encoding: encoding)?.replacingOccurrences(of: "\0", with: "")
    }
}


extension Data {
    init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
}

extension Int {
    func toData(count: Int) -> Data {
        var value = self
        return Data(bytes: &value, count: count)
    }
    
    func uint8toData() -> Data {
        let value = UInt8(self)
        return Data([value])
    }
    
    var uint8: UInt8 {
        if self < 0 {
            return UInt8(bitPattern: Int8(self))
        }
        return UInt8(self)
    }
}

extension UInt8 {
    var int: Int {
        return Int(self)
    }
    var data: Data {
        return Data([self])
    }
}

extension Int16 {
    func toData(count: Int) -> Data {
        var value = self
        return Data(bytes: &value, count: count)
    }
}

extension String {
    var toData: Data {
        return self.data(using: .utf8)!
    }
    
    var toLenData: Data {
        var data = Data()
        let self_data = self.toData
        data.append(Data([UInt8(self_data.count)]))
        data.append(self_data)
        return data
    }
}

extension DateFormatter {
    class var share: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.init(identifier: .gregorian)
        dateFormatter.locale = .init(identifier: "NL")
        return dateFormatter
    }
}

extension Double {
    var data: Data {
        return withUnsafeBytes(of: self.bitPattern.littleEndian) { Data($0) }
    }
}

extension Bool {
    var toData: Data {
        return Data([(self ? 0x01:0x00)])
    }
}
