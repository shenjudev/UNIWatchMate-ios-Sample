//
//  UIimageView+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/23.
//

import Foundation
import UIKit

extension UIImageView {
    convenience init(imageStr : String? = nil) {
        self.init()
        self.image = UIImage.init(named: imageStr ?? "")
    }
}


extension UIImage {
    
    /// 裁剪图片为圆角
    /// - Parameter radius: 圆角大小
    /// - Returns: 裁剪后的图片
    func cornerWithRadius(_ radius : CGFloat = 25) -> UIImage? {
        let size = self.size
        //开启图形上下文
         UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        //绘制圆角矩形
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        //将Path添加到上下文中
        context?.addPath(path.cgPath)
        //裁剪上下文
        context?.clip()
        //将图片绘制到上下文中
        draw(in: rect)
        context?.drawPath(using: .stroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
}
