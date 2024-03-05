//
//  UILabel+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/22.
//

import Foundation
import UIKit

extension UILabel {
    
    convenience init(text : String? = "",
                     textColor : UIColor? = .colorFFFFFF ,
                     font : UIFont? = nil) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
    }
}


extension UIFont {
    static func mediumFont( size : CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Medium", size: size) ?? UIFont()
    }
    
    static func regularFont( size : CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Regular", size: size) ?? UIFont()
    }
    
    static func semiboldFont( size : CGFloat) -> UIFont {
        return UIFont.init(name: "PingFangSC-Semibold", size: size) ?? UIFont()
    }
    
    static func heavyFont(size : CGFloat) -> UIFont {
        return UIFont.init(name: "PingFang-Heavy", size: size) ?? UIFont()
    }
    
   @objc static func bebasNeueFont(size : CGFloat) -> UIFont {
        return UIFont.init(name: "BebasNeue-Regular", size: size) ?? UIFont()
    }
    
    @objc static func barlowBoldFont(size : CGFloat) -> UIFont {
        return UIFont.init(name: "Barlow-Bold", size: size) ?? UIFont()
    }
    
    @objc static func barlowRegularFont(size : CGFloat) -> UIFont {
        return UIFont.init(name: "Barlow-Regular", size: size) ?? UIFont()
    }
    
    static func dinBlackFont(size : CGFloat) -> UIFont {
        return UIFont.init(name: "DIN-BlackItalic", size: size) ?? UIFont()
    }
    
    static func reaular16() -> UIFont {
        return UIFont.regularFont(size: 16)
    }
    
    static func reaular14() -> UIFont {
        return UIFont.regularFont(size: 14)
    }
    
    static func reaular12() -> UIFont {
        return UIFont.regularFont(size: 12)
    }
    
    static func medium12() -> UIFont {
        return UIFont.mediumFont(size: 12)
    }
    
    static func medium14() -> UIFont {
        return UIFont.mediumFont(size: 14)
    }
    
    static func medium16() -> UIFont {
        return UIFont.mediumFont(size: 16)
    }
    
    static func medium18() -> UIFont {
        return UIFont.mediumFont(size: 18)
    }
    
    static func medium24() -> UIFont {
        return UIFont.mediumFont(size: 24)
    }
}
