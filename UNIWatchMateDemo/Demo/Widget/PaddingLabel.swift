//
//  PaddingLabel.swift
//  SparkPro
//
//  Created by abel on 2024/3/28.
//  Copyright © 2024 Shenju. All rights reserved.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {
    // 定义内边距
    var padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    // 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 重写文本绘制方法以应用内边距
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    // 重写 intrinsicContentSize 属性以考虑内边距
    override var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let height = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
    
    // 重写 textRect(forBounds:limitedToNumberOfLines:) 方法以考虑内边距
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: padding)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -padding.top, left: -padding.left, bottom: -padding.bottom, right: -padding.right)
        return textRect.inset(by: invertedInsets)
    }
}
