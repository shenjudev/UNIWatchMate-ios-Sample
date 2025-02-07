//
//  SJSyncTimeLog.swift
//  SparkPro
//
//  Created by yachao on 2022/1/10.
//  Copyright © 2022 SparkPro. All rights reserved.
//

import Foundation


// 封装的日志输出功能（T表示不指定日志信息参数类型）
func SJNetLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "Net.log", message: message, file: file, function: function, line: line, level: .debug)
}

// 封装的日志输出功能（T表示不指定日志信息参数类型）
func SJLocalLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "SJLocalLog.log", message: message, file: file, function: function, line: line, level: .debug)
}


// 封装的日志输出功能（T表示不指定日志信息参数类型）
func SJLocationLog<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "location.log", message: message, file: file, function: function, line: line, level: .debug)
}

// 封装的日志输出功能（T表示不指定日志信息参数类型）
/// 降低日志登记为debug，正式release版本将不会输出--舟海日志太大，拒绝录入
func SJZHDevInfo<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "SJDevInfo.log", message: message, file: file, function: function, line: line, level: .debug)
}

// 封装的日志输出功能（T表示不指定日志信息参数类型）
func SJZHDevData<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "SJDevData.log", message: message, file: file, function: function, line: line, level: .debug)
}

// 封装的日志输出功能（T表示不指定日志信息参数类型）
func SJSJDeviceData<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
    SJLogTool.logToFile(logFile: "SJDeviceData.log", message: message, file: file, function: function, line: line, level: .info)
}

// 定义暴露给Objective-C的方法
@objc public class SJSJDeviceDataLogger: NSObject {
    @objc public class func logDeviceData(_ message: Any, file: String = #file, function: String = #function, line: Int = #line, type: String = "") {
            SJLogTool.logToFile(logFile: "SJDeviceData.log", message: message, file: file, function: function, line: line, level: .info)
        }

        @objc public class func logDeviceDataSimplified(_ message: Any) {
            self.logDeviceData(message, file: #file, function: #function, line: #line, type: "")
        }
}


