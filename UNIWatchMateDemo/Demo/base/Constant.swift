//
//  Constant.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/29.
//
import Foundation
import UIKit
// MARK: ---

let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height

var keyWindow : UIWindow? {
    UIApplication.shared.windows.filter {$0.isKeyWindow}.first
}

var topSafeHeight: CGFloat {
    if #available(iOS 11, *) {
        return  keyWindow?.safeAreaInsets.top ?? 0
    }else{
        return 0
    }
}

var bottomSafeHeight: CGFloat {
    if #available(iOS 11, *) {
        return keyWindow?.safeAreaInsets.bottom ?? 0
    }else{
        return 0
    }
}

let ISIponeX : Bool = bottomSafeHeight <= 0 ? false : true

let isIpone5s : Bool = screenWidth <= 320

let statusHeight:CGFloat = {
    var statusBarHeight: CGFloat = 0
     if #available(iOS 13.0, *) {
         let scene = UIApplication.shared.connectedScenes.first
         guard let windowScene = scene as? UIWindowScene else { return 0 }
         guard let keyWindow = windowScene.windows.first else { return 0 }
         statusBarHeight = keyWindow.safeAreaInsets.top
//          height = topHeight ?? 20
     } else {
         statusBarHeight = UIApplication.shared.statusBarFrame.height
     }
     return statusBarHeight
}()

let navigationContentHeight : CGFloat = 44
let navbarHeight = statusHeight + navigationContentHeight
let tabbarHeight = 49 + bottomSafeHeight

func RS(_ x : CGFloat) -> CGFloat {
    return x * (screenWidth / 375) * 0.5
}


// MARK: block
typealias CommonEmptyBlock = (() -> ())
typealias CommonIntBlock = ((Int?) -> ())
typealias CommonStringBlock = ((String?) -> ())
typealias CommonBoolBlock = ((Bool) -> ())

// MARK: print
func ZHLog<T>(_ message:T,file:String = #file,funcName:String = #function,lineName:Int = #line){
    #if DEBUG
        let  flieName = (file as NSString).lastPathComponent
        let formter = DateFormatter()
        formter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formter.locale = Locale(identifier: "en")
        let printDate = formter.string(from: Date())
        print("\(printDate): \(flieName) \(funcName) 第\(lineName)行: \(message)")
    #endif
}
extension ZHBaseBottomAlertView {
    public func dimiss() {
        UIView.animate(withDuration: 0.25) {
            var rect = self.contentView.frame
            rect.origin.y = screenHeight
            self.contentView.frame = rect
        } completion: { finish in
            self.removeFromSuperview()
        }
    }
    
    public func show() {
        keyWindow?.addSubview(self)
        self.layoutIfNeeded()
        self.contentView.frame.origin.y = screenHeight
        UIView.animate(withDuration: 0.25) {
            var rect = self.contentView.frame
            rect.origin.y = screenHeight - rect.height - bottomSafeHeight
            self.contentView.frame = rect
        } completion: { finish in
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchView = touches.first?.view
        if touchView?.isDescendant(of: self.contentView) != true {
            self.dimiss()
        }
    }
}

