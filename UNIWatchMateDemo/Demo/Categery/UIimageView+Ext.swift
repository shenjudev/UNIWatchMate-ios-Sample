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
    
    /// Crop the picture with rounded corners
    /// - Parameter radius: 0000
    /// - Returns: The cropped image
    func cornerWithRadius(_ radius : CGFloat = 25) -> UIImage? {
        let size = self.size
        //Open graphics context
         UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        //Draw rounded rectangles
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        //Add Path to the context
        context?.addPath(path.cgPath)
        //Crop context
        context?.clip()
        //Draw the picture into context
        draw(in: rect)
        context?.drawPath(using: .stroke)
        let output = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return output
    }
}
