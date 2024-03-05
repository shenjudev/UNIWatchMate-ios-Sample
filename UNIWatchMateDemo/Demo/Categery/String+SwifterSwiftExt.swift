//
//  String+SwifterSwiftExt.swift
//  OraimoHealth
//
//  Created by Eleven on 2021/11/25.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    #if os(iOS) || os(macOS)
    /// SwifterSwift: Bold string.
    var attributed: NSAttributedString {
        return NSAttributedString(string: self)
    }
    #endif
    
    #if canImport(AppKit) || canImport(UIKit)
    
    /// SwifterSwift: Add font to NSAttributedString.
    func font(ofSize fontSize: CGFloat, weight: UIFont.Weight = .medium) -> NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: UIFont.systemFont(ofSize: fontSize, weight: weight)])
    }
    
    func font(fontName: String, fontSize: CGFloat, weight: UIFont.Weight = .medium) -> NSAttributedString {
        guard let cFont = UIFont(name: fontName, size: fontSize) else {
            return font(ofSize: fontSize)
        }
        return NSMutableAttributedString(string: self, attributes: [.font: cFont])
    }
    
    func font(font: UIFont) -> NSAttributedString {
        return NSMutableAttributedString(string: self, attributes: [.font: font])
    }
    
    #endif

}

/// String Size
extension String {
    
    /// 获取文字真实宽度
    /// - Parameters:
    ///   - font: 字体
    ///   - height: 高度限制
    /// - Returns: 真实宽度
    func getStringTrueWidth(font: UIFont, height: CGFloat) -> CGFloat {
        let size = CGSize(width: 999, height: height)
        let trueSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return trueSize.width
    }

    
    /// 获取文字真实高度
    /// - Parameters:
    ///   - font: 字体
    ///   - width: 宽度限制
    /// - Returns: 真实高度
    func getStringTrueHeight(font: UIFont, width: CGFloat) -> CGFloat {
        let size = CGSize(width: width, height: 9999)
        let trueSize = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        return trueSize.height
    }
    
    
}
