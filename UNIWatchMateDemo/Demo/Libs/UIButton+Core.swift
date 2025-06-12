//
//  UIButton+Core.swift
//  Metabuds
//
//  Created by t_t on 2023/5/12.
//

import UIKit

extension UIButton {
    func tt_text(_ text: String?, for state: UIControl.State = .normal) -> UIButton {
        self.setTitle(text, for: state)
        return self
    }
    func tt_textColor(_ color: UIColor?, for state: UIControl.State = .normal) -> UIButton {
        self.setTitleColor(color, for: state)
        return self
    }
    func tt_font(_ font: UIFont) -> UIButton {
        self.titleLabel?.font = font
        return self
    }
    func tt_image(_ image: UIImage?, for state: UIControl.State = .normal) -> UIButton {
        self.setImage(image, for: state)
        return self
    }
    func tt_backgroundImage(_ image: UIImage?, for state: UIControl.State = .normal) -> UIButton {
        self.setBackgroundImage(image, for: state)
        return self
    }
    func tt_contentEdgeInsets(_ insets: UIEdgeInsets) -> UIButton {
        self.contentEdgeInsets = insets
        return self
    }
}
