//
//  MTLog.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/8.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - 日志级别

/// 日志级别枚举
enum MTLogLevel {
    case debug      // 调试信息
    case info       // 一般信息
    case error      // 错误信息
}

// MARK: - 日志代理协议

/// MTLog 日志代理协议
/// 用于将日志回调到 ViewController 或其他监听者
protocol MTLogDelegate: AnyObject {
    /// 接收日志回调
    /// - Parameters:
    ///   - level: 日志级别
    ///   - message: 日志消息
    ///   - file: 文件名
    ///   - line: 行号
    func mtLog(level: MTLogLevel, message: String, file: String, line: Int)
}

// MARK: - MTLog 日志类

/// OTA SDK 日志管理类
/// 支持将日志通过代理回调到 ViewController
class MTLog {
    
    /// 日志代理（弱引用）
    static weak var delegate: MTLogDelegate?
    
    /// 是否启用控制台打印（默认启用）
    static var enableConsolePrint: Bool = true
    
    /// 调试日志
    /// - Parameters:
    ///   - log: 日志内容
    ///   - line: 行号
    ///   - file: 文件名
    class func debug(_ log: Any..., line: Int = #line, file: String = #file) {
        let message = formatLog(log)
        
        // 通过代理回调
        delegate?.mtLog(level: .debug, message: message, file: file, line: line)
        
        // 控制台打印（如果启用）
        if enableConsolePrint {
            DDLogDebug(log)
        }
    }
    
    /// 信息日志
    /// - Parameters:
    ///   - log: 日志内容
    ///   - line: 行号
    ///   - file: 文件名
    class func info(_ log: Any..., line: Int = #line, file: String = #file) {
        let message = formatLog(log)
        
        // 通过代理回调
        delegate?.mtLog(level: .info, message: message, file: file, line: line)
        
        // 控制台打印（如果启用）
        if enableConsolePrint {
            DDLogInfo(log)
        }
    }
    
    /// 错误日志
    /// - Parameters:
    ///   - log: 日志内容
    ///   - line: 行号
    ///   - file: 文件名
    class func error(_ log: Any..., line: Int = #line, file: String = #file) {
        let message = formatLog(log)
        
        // 通过代理回调
        delegate?.mtLog(level: .error, message: message, file: file, line: line)
        
        // 控制台打印（如果启用）
        if enableConsolePrint {
            DDLogError(log)
        }
    }
    
    // MARK: - 私有方法
    
    /// 格式化日志内容
    /// - Parameter log: 日志参数数组
    /// - Returns: 格式化后的字符串
    private class func formatLog(_ log: [Any]) -> String {
        return log.map { "\($0)" }.joined(separator: " ")
    }
}

