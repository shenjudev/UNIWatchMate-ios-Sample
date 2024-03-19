//
//  UIColor+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/22.
//

import Foundation
import UIKit

extension UIColor {
    
    /// 24-bit hexadecimal color
    ///
    /// - Parameter hex: A 24-digit hexadecimal number
    convenience init(hex: UInt32) {
        let r = (hex & 0xff0000) >> 16
        let g = (hex & 0x00ff00) >> 8
        let b = hex & 0x0000ff
        self.init(r: UInt8(r), g: UInt8(g), b: UInt8(b))
    }
    
    /// Get UIColor
    ///
    /// - Parameters:
    /// -r: red The value ranges from 0 to 255
    /// -g: green The value ranges from 0 to 255
    /// -b: blue The value ranges from 0 to 255
    convenience init(r: UInt8, g: UInt8, b: UInt8) {
        self.init(red: CGFloat(r) / 255.0, green:  CGFloat(g) / 255.0, blue:  CGFloat(b) / 255.0, alpha: 1)
    }
    
    /// Random color
    class var random: UIColor {
        return UIColor(r: UInt8(arc4random_uniform(256)), g: UInt8(arc4random_uniform(256)), b: UInt8(arc4random_uniform(256)))
    }
    
    static var colorFFFFFF : UIColor {
        return UIColor(hex: 0xFFFFFF)
    }
  
    static var color999999 : UIColor {
        return UIColor(hex: 0x999999)
    }
    
    static var color666666 : UIColor {
        return UIColor(hex: 0x666666)
    }
    
    static var color333333 : UIColor {
        return UIColor(hex: 0x333333)
    }
    
    static var color000000 : UIColor {
        return UIColor(hex: 0x000000)
    }
    
    static var color23ED67 : UIColor {
        return UIColor(hex: 0x23ED67)
    }
    static var color2CFF00 : UIColor {
        return UIColor(hex: 0x2CFF00)
    }
    
    static var colorF64054 : UIColor {
        return UIColor(hex: 0xF64054)
    }
    
    static var colorFF3F0C : UIColor {
        return UIColor(hex: 0xFF3F0C)
    }
    
    static var colorC5A5FF : UIColor {
        return UIColor(hex: 0xC5A5FF)
    }
    
    static var color06B4B2:UIColor {
        return UIColor(hex: 0x06B4B2)
    }
    
    static var color101112 : UIColor {
        return UIColor(hex: 0x101112)
    }
    
    static var color1B1C1E : UIColor {
        return UIColor(hex: 0x1B1C1E)
    }
    
    static var colorFF754E : UIColor {
        return UIColor(hex: 0xFF754E)
    }
    
    static var color95D600 : UIColor {
        return UIColor(hex: 0x95D600)
    }
    
    static var color4763FF  : UIColor {
        return UIColor(hex: 0x4763FF )
    }
    
    static var color191A1B  : UIColor {
        return UIColor(hex: 0x191A1B )
    }
    
    static var color171819 : UIColor {
        return UIColor(hex: 0x171819)
    }
    
    static var colorFF0200 : UIColor {
        return UIColor(hex: 0xFF0200)
    }
    
    static var colorFF5353 : UIColor {
        return UIColor(hex: 0xFF5353)
    }
    
    static var color1FAD4F : UIColor {
        return UIColor(hex: 0x1FAD4F)
    }
    
    static var color959495 : UIColor {
        return UIColor(hex: 0x959495)
    }
    
    static var color1F2020 : UIColor {
        return UIColor(hex: 0x1F2020)
    }
    
    static var color080808 : UIColor {
        return UIColor(hex: 0x080808)
    }
}

