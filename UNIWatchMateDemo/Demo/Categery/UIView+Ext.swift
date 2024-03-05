//
//  UIView+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/22.
//

import Foundation
import UIKit

extension UIView {
    func addTapGeseTure(_ target : Any? , _ selector : Selector?) {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: target, action: selector)
        self.addGestureRecognizer(tap)
    }
    
    @discardableResult
    func addGradient(colors: [UIColor],
                     point: (CGPoint, CGPoint) = (CGPoint(x:1, y: 0), CGPoint(x: 1, y: 1)),
                     radius: CGFloat = 0) -> CAGradientLayer {
        let bgLayer = CAGradientLayer()
        bgLayer.colors = colors.map { $0.cgColor }
        bgLayer.frame = self.bounds
        bgLayer.locations = [0 , 0.8]
        bgLayer.startPoint = point.0
        bgLayer.endPoint = point.1
        bgLayer.cornerRadius = radius
        self.layer.addSublayer(bgLayer)
        return bgLayer
    }
    
    func toImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        return image
    }
}

