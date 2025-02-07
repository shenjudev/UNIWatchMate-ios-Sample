//
//  SJLogBase.swift
//  SparkPro
//
//  Created by yachao on 2021/11/22.
//  Copyright © 2023 SparkPro. All rights reserved.
//

import Foundation

public enum SJLogLevel: String {
    case nolog = ""
    case info = "Info"
    case debug = "Debug"
    case error = "Error"
    case crash = "Crash"
    
    public var level: Int {
        get {
            switch self {
            case .crash: return 0
            case .error: return 1
            case .info: return 2
            case .debug: return 3
            default:
                return 4
            }
        }
    }
}
public var isLog = true

public class SJLogBase {
//    /// 是否打印日志 默认为true
//    public static var isLog = true


    static let logDir = "SJLogFile"
    private static let logQueue = DispatchQueue(label: "com.transsion.SparkPro.log.queue", qos: .utility)
    
    public static var logDirUrl: URL {
        let documentDirUrl = Self.documentDirUrl
        let _logDirUrl = documentDirUrl.appendingPathComponent(Self.logDir)
        
        return _logDirUrl
    }
    
    /// 根据文件名获取日志URL
    static func getLogUrl(with name: String) -> URL {
        let logUrl: URL = logDirUrl.appendingPathComponent(name)
        
        return logUrl
    }
    
    /// 根据文件名获取当前的文件名
    static func getLogName(with name: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en")
        let now = dateFormatter.string(from: Date())
        let logName = now + "-" + name
        
        return logName
    }
    
    static func getLogMessage<T>(_ message: T, file: String, function: String, line: Int, level: SJLogLevel) -> String {
        // 日志内容
        let file = (file as NSString).lastPathComponent
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "zh-Hans")
        let curDateStr = dateFormatter.string(from: Date())
        
        let timeZone = NSTimeZone.local.localizedName(for: .shortStandard, locale: dateFormatter.locale) ?? ""
        var logMessage = ""
        if line > 0 {
            logMessage = "[\(curDateStr) L: \(timeZone)] [\(level)] [\(file) \(function)] [line \(line)] \(message) \n"
        }
        else {
            logMessage = "[\(curDateStr)] [\(level)] \(message) \n"
        }
        
        return logMessage
    }
    
    /// 写日志到日志文件
    static func writeLogTo<T>(logFile: String, message: T, file: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel) {
        if level == .crash {
            syncWriteLogTo(logFile: logFile, message: message, file: file, function: function, line: line, level: level)
        } else {
            asyncWriteLogTo(logFile: logFile, message: message, file: file, function: function, line: line, level: level)
        }
    }
    
    /// 异步写日志
    private static func asyncWriteLogTo<T>(logFile: String, message: T, file: String, function: String, line: Int, level: SJLogLevel) {
        logQueue.async {
            writeLog(logFile: logFile, message: message, file: file, function: function, line: line, level: level)
        }
    }
    
    /// 同步写日志
    private static func syncWriteLogTo<T>(logFile: String, message: T, file: String, function: String, line: Int, level: SJLogLevel) {
        writeLog(logFile: logFile, message: message, file: file, function: function, line: line, level: level)
    }
    
    /// 写日志
    private static func writeLog<T>(logFile: String, message: T, file: String, function: String, line: Int, level: SJLogLevel) {
        
        switch level {
        case .debug:
            #if DEBUG
            break
            #else
            if !isLog {
                return
            }
            #endif
            
        case .info:
            break
            
        case .error:
            break
            
        case .crash:
            break
            
        default:
            return
        }
        
        let logMessage = getLogMessage(message, file: file, function: function, line: line, level: level)
        
        #if DEBUG
        print(logMessage)
        #endif
        
        var logFile = logFile
        if logFile.isEmpty {
            logFile = "SJLog.log"
        } else {
            if logFile.pathExtension == "" {
                logFile += ".log"
            }
        }
        
        let logFileName = getLogName(with: logFile)
        let logUrl = getLogUrl(with: logFileName)
        
        writeStringTo(fileURL: logUrl, string: logMessage)
    }
    
    /// 打印日志
    public static func log<T>(logFile: String = "", message: T, file: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel = .nolog) {
        writeLogTo(logFile: logFile, message: message, file: file, function: function, line: line, level: level)
    }
    
    /// 打印默认文件日志
    public static func log<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel = .info) {
        log(message: message, file: file, function: function, line: line, level: level)
    }
    
    /// 打印日志
    public static func logInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .info)
    }
    
    /// 打印调试信息
    public static func logDebug<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .debug)
    }
    
    /// 打印错误日志
    public static func logError<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .error)
    }
    
    /// 打印奔溃日志
    public static func logCrash<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .crash)
    }
}

// MARK: - File path
fileprivate extension SJLogBase {
    
    /// 沙盒DocumentDirectory
    static var documentDirUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}


// MARK: - 写文件
fileprivate extension SJLogBase {
    
    /// 将string写入到文件末尾
    static func writeStringTo(fileURL: URL, string: String) {
        do {
            if !fileURL.isFileURL {
                return
            }
            
            if string.isEmpty {
                return
            }
            
            // 创建文件夹
            let dir = fileURL.deletingLastPathComponent()
            var isDir: ObjCBool = true
            if !FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDir) {
                // 自动创建中间不存在的目录
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            }
            
            // 如果文件不存在则新建一个
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                FileManager.default.createFile(atPath: fileURL.path, contents: nil)
                removeOldFile(dir.path)
            }
            

            let fileHandle = try FileHandle(forWritingTo: fileURL)
            let stringToWrite = string + "\n"

            // 找到末尾位置并添加
            fileHandle.seekToEndOfFile()
            if let sData = stringToWrite.data(using: String.Encoding.utf8) {
                fileHandle.write(sData)
            }
            fileHandle.closeFile()
        } catch let error as NSError {
            print(error)
        }
    }
    
    static var isRemove = false
    static let documentPath = NSHomeDirectory() + "/Documents"
    static let days = isLog ? 15 : 3
    
    /// 删除文件夹中时间超过15天的日志文件
    /// - Parameter path: 文件夹路径
    static func removeOldFile(_ path: String) {
        if isRemove {
            return
        }
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            if let subPaths = fileManager.subpaths(atPath: path) {
                let oldDate = Date().adding(.day, value: -days)
                for item in subPaths {
                    if item.count > 10 {
                        let fileDateStr = (item as NSString).substring(to: 10)
                        if let fileDate = fileDateStr.date, fileDate.compare(oldDate) == .orderedAscending {
                            let fileName = path.appendingPathComponent(item)
                            try? fileManager.removeItem(atPath: fileName)
                        }
                    }
                }
            }
        }
        
        isRemove = true
    }
    
 
}
