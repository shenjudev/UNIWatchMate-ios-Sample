//
//  Date+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/25.
//

import Foundation

extension Date {
    static func currentTime() -> String {
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "YYYY-MM-dd HH:mm:ss"// 自定义时间格式
        
        // GMT时间 转字符串，直接是系统当前时间
        
        return dateformatter.string(from: Date())
        
    }
    
    func currentTimeStamp() -> TimeInterval {
        
        let date = Date()
        
        // GMT时间转时间戳 没有时差，直接是系统当前时间戳
        
        return date.timeIntervalSince1970
        
    }
    
    var lastWeek: Date {
        return calendar.date(byAdding: .day, value: -7, to: self) ?? Date()
    }
    
    var nextWeek: Date {
        return calendar.date(byAdding: .day, value: 7, to: self) ?? Date()
    }
    
    var lastMonth: Date {
        return calendar.date(byAdding: .month, value: -1, to: self) ?? Date()
    }
    
    
    var nextMonth: Date {
        return calendar.date(byAdding: .month, value: 1, to: self) ?? Date()
    }
    
    var lastYear: Date {
        return calendar.date(byAdding: .year, value: -1, to: self) ?? Date()
    }
    
    var nextYear: Date {
        return calendar.date(byAdding: .year, value: 1, to: self) ?? Date()
    }
    
}
