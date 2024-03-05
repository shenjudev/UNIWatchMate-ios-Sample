//
//  NSAttributedString+SwifterSwiftExt.swift
//  OraimoHealth
//
//  Created by Eleven on 2023/12/21.
//  Copyright © 2023 Transsion-Oraimo. All rights reserved.
//

import Foundation

// MARK: - Methods
public extension NSAttributedString {
    
#if !os(Linux)
    /// SwifterSwift: Applies given attributes to the new instance of NSAttributedString initialized with self object
    ///
    /// - Parameter attributes: Dictionary of attributes
    /// - Returns: NSAttributedString with applied attributes
    func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (string as NSString).range(of: string)
        copy.addAttributes(attributes, range: range)
        
        return copy
    }
#endif
    
}
