//
//  UILabel+Core.swift
//  Metabuds
//
//  Created by t_t on 2023/5/12.
//

import UIKit

extension UILabel {
    func tt_text(_ text: String?) -> UILabel {
        self.text = text
        return self
    }
    func tt_font(_ font: UIFont) -> UILabel {
        self.font = font
        return self
    }
    func tt_numberOfLines(_ numberOfLines: Int) -> UILabel {
        self.numberOfLines = numberOfLines
        return self
    }
    func tt_textColor(_ textColor: UIColor) -> UILabel {
        self.textColor = textColor
        return self
    }
    func tt_textAlignment(_ textAlignment: NSTextAlignment) -> UILabel {
        self.textAlignment = textAlignment
        return self
    }
    func tt_attributedText(_ attributedText: NSAttributedString?) -> UILabel {
        self.attributedText = attributedText
        return self
    }
}
