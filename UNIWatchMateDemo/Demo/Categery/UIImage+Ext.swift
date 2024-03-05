//
//  UIImage+Ext.swift
//  OraimoHealth
//
//  Created by Eleven on 2022/11/25.
//  Copyright © 2022 Transsion-Oraimo. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public func combinImage(image: UIImage) ->UIImage {
        let width = max(self.size.width, image.size.width)
        let height = self.size.height + image.size.height
        let offScreenSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContext(offScreenSize)
        
        let rect = CGRect(x:0, y:0, width:width, height:self.size.height)
        self.draw(in: rect)
        
        let rect2 = CGRect.init(x:0, y:self.size.height, width:width, height:image.size.height)
        image.draw(in: rect2)

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();

        return newImage;

    }
    
    public func combinImage(with image: UIImage, imageoffset: CGPoint = .zero, imageBgColor: UIColor = .clear) ->UIImage {
        let width = max(self.size.width, image.size.width)
        let height = self.size.height + image.size.height + imageoffset.y
        let offScreenSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(offScreenSize, false, 0)

//        UIGraphicsBeginImageContext(offScreenSize)
        
        let context = UIGraphicsGetCurrentContext()!
   
        context.setFillColor(imageBgColor.cgColor)
        context.setStrokeColor(imageBgColor.cgColor)
        let rect = CGRect(x:0, y:0, width:width, height:self.size.height)
        self.draw(in: rect)
        
        let rect2 = CGRect(x: 0, y: self.size.height + imageoffset.y, width:width, height:image.size.height)
        image.draw(in: rect2)

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();

        return newImage;

    }
}

extension UIImage {
    class func oh_shareBg_image(named name: String) -> UIImage? {
        return OHShareAssets.bundledSportShareBgImage(named: name)
    }
    
    class func oh_common_image(named name: String) -> UIImage? {
        return OHShareAssets.bundledCommonImage(named: name)
    }
}

open class OHShareAssets: NSObject {
    
    internal class func bundledSportShareBgImage(named name: String) -> UIImage? {
        let path = Bundle.main.path(forResource: "oraimoImage", ofType: "bundle")
//        let bundle = Bundle(path: path!)

        let imgPath = path?.appendingPathComponent("SportShareBg").appendingPathComponent(name) ?? ""
        
        return UIImage(contentsOfFile: imgPath)

    }
    
    internal class func bundledCommonImage(named name: String) -> UIImage? {
        let path = Bundle.main.path(forResource: "oraimoImage", ofType: "bundle")
//        let bundle = Bundle(path: path!)

        let imgPath = path?.appendingPathComponent("Common").appendingPathComponent(name) ?? ""
        
        return UIImage(contentsOfFile: imgPath)

    }

}
