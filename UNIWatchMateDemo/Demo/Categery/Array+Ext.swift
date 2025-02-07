//
//  Array+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/25.
//

import Foundation

extension Array {
    //创建数组
    static func incrementArrs(start : Int , end : Int , interval : Int = 1) -> Array<String> {
        let arrsCount = (end - start) / interval
        var arrs : [String] = []
        if arrsCount <= 0 {
            return ["\(start)"]
        }
         for i in 0...arrsCount {
            arrs.append("\(start + i * interval)")
        }
        return arrs
    }
    
    //创建数组
    static func incrementNumbersArrs(start : Int , end : Int , interval : Int = 1) -> Array<Int> {

        let arrsCount = (end - start) / interval
        var arrs : [Int] = []
        if arrsCount <= 0 {
            return [start]
        }
         for i in 0...arrsCount {
            arrs.append(start + i * interval)
        }
        return arrs
    }
        
    //创建数组
    static func incrementArrs(start : Int , count : Int , interval : Int = 1) -> Array<String> {
        var arrs : [String] = []
        if count <= 0 {
            return ["\(start)"]
        }
        for i in 0...count {
            arrs.append("\(start + i * interval)")
        }
        return arrs
    }
    
}

