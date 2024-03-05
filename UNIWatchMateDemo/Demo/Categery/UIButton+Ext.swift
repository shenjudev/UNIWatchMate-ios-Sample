//
//  UIButton+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/22.
//

import Foundation
import UIKit
//import RESegmentedControl

extension UIButton {
    
    convenience init(title : String? = "" ,
                     textColor : UIColor? = UIColor(hex: 0xFFFFFF) ,
                     font : UIFont? = UIFont.mediumFont(size: 16)) {
        self.init(type: .custom)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.setTitleColor(textColor, for: .normal)
    }
    
    convenience init(title : String? = "" ,
                     textColor : UIColor? = UIColor(hex: 0xFFFFFF) ,
                     font : UIFont? = UIFont.mediumFont(size: 16) ,
                     target : Any? = nil,
                     selector : Selector) {
        self.init(type: .custom)
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        self.setTitleColor(textColor, for: .normal)
        self.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    convenience init(normalImg : String? = nil
                     ,selectImg : String? = nil ,
                     target : Any? = nil,
                     selector : Selector) {
        self.init(type: .custom)
        if let tempNor = normalImg {
            self.setImage(UIImage.init(named: tempNor), for: .normal)
        }
        
        if let tempSel = selectImg {
            self.setImage(UIImage.init(named: tempSel), for: .selected)
        }
        
        self.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    convenience init(normalImg : String? = nil
                     ,selectImg : String? = nil) {
        self.init(type: .custom)
        if let tempNor = normalImg {
            self.setImage(UIImage.init(named: tempNor), for: .normal)
        }
        
        if let tempSel = selectImg {
            self.setImage(UIImage.init(named: tempSel), for: .selected)
        }
    }
    
    func itemAlpha(_ isVaild : Bool = false) {
        if isVaild == false {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.2)
            self.setTitleColor(self.titleColorForNormal?.withAlphaComponent(0.2), for: .normal)
        }else{
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.85)
            self.setTitleColor(self.titleColorForNormal?.withAlphaComponent(1), for: .normal)
        }
    }
    
}

// MARK: - 倒计时
extension UIButton{
    
    public func countDown(count: Int ,completion:(() -> ())?){
        // 倒计时开始,禁止点击事件
        isEnabled = false
        
        // 保存当前的背景颜色
        let defaultColor = self.backgroundColor
        let defaultTitle = self.titleForNormal ?? ""
        // 设置倒计时,按钮背景颜色
        //backgroundColor = UIColor.gray
        
        var remainingCount: Int = count {
            willSet {
                setTitle("\(newValue)s", for: .normal)
                
                if newValue <= 0 {
                    setTitle(defaultTitle, for: .normal)
                }
            }
        }
        
        // 在global线程里创建一个时间源
        let codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: {
            
            // 返回主线程处理一些事件，更新UI等等
            DispatchQueue.main.async {
                // 每秒计时一次
                remainingCount -= 1
                // 时间到了取消时间源
                if remainingCount <= 0 {
                    self.backgroundColor = defaultColor
                    self.isEnabled = true
                    codeTimer.cancel()
                    completion?()
                }
            }
        })
        // 启动时间源
        codeTimer.resume()
    }
    
}

// MARK: - 倒计时
extension UIButton {
    enum TSButtonImagePosition {
        
    case top          //图片在上，文字在下，垂直居中对齐
        
    case bottom      //图片在下，文字在上，垂直居中对齐
        
    case left        //图片在左，文字在右，水平居中对齐
        
    case right        //图片在右，文字在左，水平居中对齐
        
    }
    
func imagePosition(style: TSButtonImagePosition, spacing: CGFloat) {
        
    let imageWidth = self.imageView?.frame.size.width
        
    let imageHeight = self.imageView?.frame.size.height
        
    var labelWidth: CGFloat! = 0.0
        
    var labelHeight: CGFloat! = 0.0
        
    labelWidth = self.titleLabel?.intrinsicContentSize.width
        
    labelHeight = self.titleLabel?.intrinsicContentSize.height
        
    var imageEdgeInsets =  UIEdgeInsets.zero
        
    var labelEdgeInsets = UIEdgeInsets.zero
        
    switch style {
            
        case.top:
            
        imageEdgeInsets = UIEdgeInsets(top: -labelHeight-spacing/2,left:0,bottom:0,right: -labelWidth)
            
        labelEdgeInsets = UIEdgeInsets(top:0,left: -imageWidth!,bottom: -imageHeight!-spacing/2,right:0)
            
        break;
            
        case.left:
            
        imageEdgeInsets = UIEdgeInsets(top:0,left: -spacing/2,bottom:0,right: spacing)
            
        labelEdgeInsets = UIEdgeInsets(top:0,left: spacing/2,bottom:0,right: -spacing/2)
            
        break;
            
        case.bottom:
            
        imageEdgeInsets = UIEdgeInsets(top:0,left:0,bottom: -labelHeight!-spacing/2,right: -labelWidth)
            
        labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-spacing/2,left: -imageWidth!,bottom:0,right:0)
            
        break;
            
        case.right:
            
        imageEdgeInsets = UIEdgeInsets(top:0,left: labelWidth+spacing/2,bottom:0,right: -labelWidth-spacing/2)
            
        labelEdgeInsets = UIEdgeInsets(top:0,left: -imageWidth!-spacing/2,bottom:0,right: imageWidth!+spacing/2)
            
        break;
            
        }
        
    self.titleEdgeInsets = labelEdgeInsets
        
    self.imageEdgeInsets = imageEdgeInsets

    }

}

// MARK:  防止按钮连点
//public extension UIButton {
//
//    private struct AssociatedKeys {
//        static var eventInterval = "eventInterval"
//        static var eventUnavailable = "eventUnavailable"
//    }
//
//    /// 重复点击的时间 属性设置
//    var eventInterval: TimeInterval {
//        get {
//            if let interval = objc_getAssociatedObject(self, &AssociatedKeys.eventInterval) as? TimeInterval {
//                return interval
//            }
//            return 0.1
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.eventInterval, newValue as TimeInterval, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//    /// 按钮不可点 属性设置
//    private var eventUnavailable : Bool {
//        get {
//            if let unavailable = objc_getAssociatedObject(self, &AssociatedKeys.eventUnavailable) as? Bool {
//                return unavailable
//            }
//            return false
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.eventUnavailable, newValue as Bool, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//
//    /// 新建初始化方法,在这个方法中实现在运行时方法替换
//    class func initializeMethod() {
//        let selector = #selector(UIButton.sendAction(_:to:for:))
//        let newSelector = #selector(new_sendAction(_:to:for:))
//
//        let method: Method = class_getInstanceMethod(UIButton.self, selector)!
//        let newMethod: Method = class_getInstanceMethod(UIButton.self, newSelector)!
//
//        if class_addMethod(UIButton.self, selector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) {
//            class_replaceMethod(UIButton.self, newSelector, method_getImplementation(method), method_getTypeEncoding(method))
//        } else {
//            method_exchangeImplementations(method, newMethod)
//        }
//    }
//
//    /// 在这个方法中
//    @objc private func new_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
//        if eventUnavailable == false {
//            eventUnavailable = true
//            new_sendAction(action, to: target, for: event)
//            // 延时
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + eventInterval, execute: {
//                self.eventUnavailable = false
//            })
//        }
//    }
//}
