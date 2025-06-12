//
//  UIImageView+Core.swift
//  Metabuds
//
//  Created by t_t on 2023/5/12.
//

import UIKit

extension UIImageView {
    func tt_image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    func tt_contentMode(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }
}
