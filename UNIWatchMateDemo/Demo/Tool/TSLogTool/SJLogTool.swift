//
//  SJLogTool.swift
//  SparkPro
//
//  Created by yachao on 2021/11/22.
//  Copyright © 2023 SparkPro. All rights reserved.
//

import Foundation
///debug模式下 输出日志 并记录入Debug文件
func DDLogDebug<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    
    SJLogTool.logDebug(message, file: file, function: function, line: line)
}

///debug模式下 输出日志 并记录入Info文件
func DDLogInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    
    SJLogTool.logInfo(message, file: file, function: function, line: line)
}

///输出日志 并记录入Error文件
func DDLogError<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
    
    SJLogTool.logError(message, file: file, function: function, line: line)
}


///debug模式下 仅输出日志
func DDPrint<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line)  {
    #if DEBUG
    let curDateStr = (Date().string(withFormat:"MM-dd HH:mm:ss sss"))
    let logMessage = "[\(curDateStr)] [\(file) \(function)] [line \(line)] \(message) \n"
    print(logMessage)
    #endif
}

/// UI操作日志
extension SJLogTool {
    
    /// 界面操作日志 （UIOperation）
    static func logUIOperation<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        logToFile(logFile: "UIOperation.log", message: message, file: file, function: function, line: line, level: .debug)
    }
    
}
///苹果健康日志
extension SJLogTool {
    static func logHealth<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        logToFile(logFile: "aHealth.log", message: message, file: file, function: function, line: line, level: .debug)
    }
}
let systemVersion = UIDevice.current.systemVersion
let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

class SJLogTool {
    
    static func getLogMessage<T>(_ message: T) -> String {

        /// 手机系统版本
        let sysVersion = systemVersion
        // 日志内容
        let logMessage = "[IOSVersion: \(sysVersion)]  \(message)"
        
        return logMessage
    }
    
    static func logDebug<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .debug)
    }
    
    static func logInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .info)
    }
    
    /// 打印错误日志
    static func logError<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .error)
    }
    
    /// 打印crash日志
    static func logCrash<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, file: file, function: function, line: line, level: .crash)
    }
    
    /// 打印日志到文件
    static func logToFile<T>(logFile: String = "", message: T, file: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel = .info) {
        var logFileName = currentVersion
        if !logFile.isEmpty {
            logFileName = logFileName + "-" + logFile
        } else {
            logFileName = logFileName + "-" + "SJLog.log"
        }
        
        wirteLogToFile(logFile: logFileName, message: message, codeFile: file, function: function, line: line, level: level)
    }
    
    
    
    /// 打印日志
    static func log<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel = .info) {
        logToFile(message: message, file: file, function: function, line: line, level: level)
    }
    
    fileprivate static func wirteLogToFile<T>(logFile: String = "", message: T, codeFile: String = #file, function: String = #function, line: Int = #line, level: SJLogLevel = .info) {
        var msgStr = ""
        #if DEBUG
        msgStr = getLogMessage(message)
        #else
//        if isLog || level.level < 3 {
//            msgStr = getLogMessage(message)
//        }
        #warning("--ss 因日志问题，限制一下输出")
        if level.level < 3 {
            msgStr = getLogMessage(message)
        }
        #endif
        
        if msgStr.isEmpty == false {
            SJLogBase.log(logFile: logFile, message: msgStr, file: codeFile, function: function, line: line, level: level)
        }
    }
}
