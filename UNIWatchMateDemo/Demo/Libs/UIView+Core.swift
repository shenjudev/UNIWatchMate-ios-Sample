//
// Created by t_t on 2023/5/11.
//

import UIKit

extension UIView {
    func tt_frame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    func tt_color(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    func tt_radius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        return self
    }
    func tt_userInteractionEnabled(_ enabled: Bool) -> Self {
        self.isUserInteractionEnabled = enabled
        return self
    }
    func addGradientBackgroundWithRoundedCorners( fromColor: UIColor, toColor: UIColor, cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        // 设置渐变颜色
        gradientLayer.colors = [fromColor, toColor]
        
        // 设置渐变的起始点和结束点（垂直渐变）
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        // 设置圆角
        gradientLayer.cornerRadius = cornerRadius
        
        // 将渐变图层添加到view的图层中
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        // 也为UIView的layer设置圆角，以确保视图的其他部分（如边框等）也能呈现圆角效果
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true // 这一步很重要，它会裁剪掉超出圆角部分的内容
    }
    func tt_borderWidth(_ width: CGFloat) -> Self {
        self.layer.borderWidth = width
        return self
    }
    func tt_borderColor(_ color: UIColor) -> Self {
        self.layer.borderColor = color.cgColor
        return self
    }
    
}

extension UIView {
    var tt_width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
    var tt_height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    var tt_x: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    var tt_y: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    var tt_size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.frame.size = newValue
        }
    }
}
extension UIView {
    /// 设置视图的圆角
    /// - Parameters:
    ///   - corners: 需要设置圆角的角
    ///   - radius: 圆角的半径
    func setCornerRadius(corners: UIRectCorner, radius: CGFloat) {
            self.layer.cornerRadius = radius
            
            // 将UIRectCorner转换为CACornerMask
            var cornerMask: CACornerMask = []
            
            if corners.contains(.topLeft) {
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if corners.contains(.topRight) {
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if corners.contains(.bottomLeft) {
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            
            self.layer.maskedCorners = cornerMask
            self.layer.masksToBounds = true
    }
    
    /// 使用maskedCorners设置视图的圆角
    /// - Parameters:
    ///   - corners: 需要设置圆角的角，使用CACornerMask
    ///   - radius: 圆角的半径
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        self.layer.masksToBounds = true
    }
    
    /// 便捷方法：设置指定方向的圆角
    /// - Parameter radius: 圆角半径
    func roundTopCorners(radius: CGFloat) {
        self.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: radius)
    }
    
    /// 便捷方法：设置底部圆角
    /// - Parameter radius: 圆角半径
    func roundBottomCorners(radius: CGFloat) {
        self.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: radius)
    }
}
