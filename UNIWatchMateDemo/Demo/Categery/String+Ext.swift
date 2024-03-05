//
//  String+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/22.
//

import Foundation
import UIKit

extension String {
    /// 是否为空字符串
    var isBlank: Bool {
        // 扔掉 空格和换行符
        let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedStr.isEmpty
    }
}

// MARK: 富文本相关
extension String {

    
    /// 设置富文本字体大小和颜色
    /// - Parameters:
    ///   - rangeStr: 需要添加字符串
    ///   - color: 颜色
    ///   - font: 字体
    /// - Returns: 富文本
    func addAttribute(rangeStr : String? ,
                      color : UIColor? = nil ,
                      font : UIFont? = nil) -> NSAttributedString{
        let attribute = NSMutableAttributedString.init(string: self)
        let range = (self as NSString).range(of: rangeStr ?? "")
        if let tempFont = font {
            attribute.addAttribute(NSAttributedString.Key.font, value: tempFont, range: range)
        }
        if let tempColor = color {
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: tempColor, range: range)
        }
        
        return attribute
    }
    
    
    /// 时间转成12 小时显示
    /// - Parameters:
    ///   - color: 颜色
    ///   - font: 字体
    /// - Returns: NSAttributedString
    func add12HourAttribute(color : UIColor? = nil ,
                            font : UIFont? = nil) -> NSAttributedString {
        var timeStr = ""
        if Locale.current.is12HourTimeFormat {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.locale = Locale(identifier: "en")
            
            let date = dateFormatter.date(from: self) ?? Date()
            dateFormatter.dateFormat = "hh:mm aa"
            timeStr = dateFormatter.string(from: date)
        }else{
            timeStr = self
        }
        let attribute = NSMutableAttributedString.init(string: timeStr)
    
        if timeStr.count <= 5  {
            return attribute
        }
        
        let range = NSRange(location: 5  , length: timeStr.count - 5)
        if let tempFont = font {
            attribute.addAttribute(NSAttributedString.Key.font, value: tempFont, range: range)
        }
        if let tempColor = color {
            attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: tempColor, range: range)
        }
        return attribute
    }
    
    /// 含有多个文案的富文本
    /// - Parameters:
    ///   - texts: text
    ///   - color: color
    ///   - font: font
    /// - Returns: NSAttributedString
    func addAttributes(texts : [String]? ,
                      color : UIColor? = nil ,
                      font : UIFont? = nil) -> NSAttributedString {
        
        let attribute = NSMutableAttributedString.init(string: self)
        for str in texts ?? [] {
            if self.contains(str) == true {
                let range = (self as NSString).range(of: str)
                if let tempFont = font {
                    attribute.addAttribute(NSAttributedString.Key.font, value: tempFont, range: range)
                }
                if let tempColor = color {
                    attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: tempColor, range: range)
                }
            }
        }
        return attribute
    }
    
    /// 调整
    /// - Parameters:
    ///   - texts: text
    ///   - color: color
    ///   - font: font
    /// - Returns: NSAttributedString
    func addAttributes(lineSpacing : Float) -> NSAttributedString {
        
        let attribute = NSMutableAttributedString.init(string: self)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        attribute.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: self.count))
        return attribute
    }
}


extension String {
    
    /// 验证邮箱格式是否正确
    /// - Returns: true 是 false 否
    func validateEmail() -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let str: NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return  str.evaluate(with: self)
    }
    
    /// 验证手机号码是否正确
    /// - Returns: true 是 false 否
    func validateMobile() -> Bool {
        if self.count <= 0 {
            return false
        }
        let phoneRegex: String = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let str = NSPredicate.init(format: "SELF MATCHES %@", phoneRegex)
        return str.evaluate(with: self)
    }
    
    
    /// 检测是否全是数字
    /// - Returns:  true 是 false 否
    func validateNumber() -> Bool{
        if self.count <= 0 {
            return false
        }
        let phoneRegex: String = "[0-9]*"
        let str = NSPredicate.init(format: "SELF MATCHES %@", phoneRegex)
        return str.evaluate(with: self)
    }
    
    //密码正则  6-8位字母和数字组合
    func isPasswordRuler() -> Bool {
        if self.count <= 0 {
            return false
        }
        let passwordRule = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$"
        let str = NSPredicate(format: "SELF MATCHES %@",passwordRule)
        return str.evaluate(with: self)
    }
    
    /// 判断是不是Emoji
    ///
    /// - Returns: true false
    func containsEmoji()->Bool{
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F,
                0x1F300...0x1F5FF,
                0x1F680...0x1F6FF,
                0x2600...0x26FF,
                0x2700...0x27BF,
                0xFE00...0xFE0F,
                0x1F900...0x1F9FF:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// 判断是不是Emoji
    ///
    /// - Returns: true false
    func hasEmoji()->Bool {
        return unicodeScalars.contains { $0.properties.isEmojiPresentation }
    }

    /// 判断是不是九宫格
    ///
    /// - Returns: true false
    func isNineKeyBoard()->Bool{
        let other : NSString = "➋➌➍➎➏➐➑➒"
        let len = self.count
        for _ in 0 ..< len {
            if !(other.range(of: self).location != NSNotFound) {
                return false
            }
        }
        
        return true
    }
    
    /// 去除字符串中的表情
    ///
    /// - Parameter text: text
    func disable_emoji(text : NSString)->String{
        do {
            let regex = try NSRegularExpression(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: NSRegularExpression.Options.caseInsensitive)
            
            let modifiedString = regex.stringByReplacingMatches(in: text as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, text.length), withTemplate: "")
            
            return modifiedString
        } catch {
            print(error)
        }
        return ""
    }
    
    func byteCount(maxCount : Int) -> (Int , Int) {
        var location : Int = 0
        var textCount : Int = 0
        for i in 0..<self.count {
            let str = String(self[self.index(self.startIndex, offsetBy: i)])
            textCount += str.utf8.count
            if textCount <= maxCount {
                location = i + 1
            }
        }
        return (textCount, location)
    }
    
    func getLocal(date format : String) -> Date? {
            
        let dateFormatter = DateFormatter.init()

        // UTC 时间格式
        dateFormatter.dateFormat = format
        let utcTimeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = utcTimeZone
        dateFormatter.locale = Locale(identifier: "en")
        let date = dateFormatter.date(from: self)
        return date
    }
}

extension String {
    func zh_widthForComment(font: UIFont, height: CGFloat = 15) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func zh_heightForComment(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func zh_heightForComment(font: UIFont, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
}

extension Character {
    /// 简单的emoji是一个标量，以emoji的形式呈现给用户
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else{
            return false
        }
        return unicodeScalars.count >= 1 &&
            (firstProperties.isEmojiPresentation ||
                firstProperties.generalCategory == .otherSymbol)
    }

    /// 检查标量是否将合并到emoji中
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count >= 1 &&
            unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }

    /// 是否为emoji表情
    /// - Note: http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
    var isEmoji:Bool{
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

extension String {
    /// 是否为单个emoji表情
    var isSingleEmoji: Bool {
        return count == 1 && isContainsEmoji
    }

    /// 包含emoji表情
    var isContainsEmoji: Bool {
        return contains{ $0.isEmoji}
    }

    /// 只包含emoji表情
    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains{ !$0.isEmoji }
    }

    /// 提取emoji表情字符串
    var emojiString: String {
        return emojis.map{String($0) }.reduce("",+)
    }

    /// 提取emoji表情数组
    var emojis: [Character] {
        return filter{ $0.isEmoji}
    }

    /// 提取单元编码标量
    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji}.flatMap{ $0.unicodeScalars}
    }
}
