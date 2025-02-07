//
//  TSAlertManagerTools.swift
//  OraimoHealth
//
//  Created by tanghan on 2022/7/25.
//  Copyright © 2022 Transsion-Oraimo. All rights reserved.
//



import UIKit

enum TSAlertLevel : Int {
    case None = 0
    case Low = 1
    case Middle = 2
    case High = 3
}

protocol TSAlertProtocol  {

    /// 打开新的试图
    func showAnimation(_ isCreate:Bool)
    // 弹窗消失
    func dismiss(commotion:CommonEmptyBlock?)
    // 获取内存地址
    func getAddress() -> String
    // 获取试图是否隐藏
    func getCurrentHidden() -> Bool
    // 获取当前弹窗的等级
    func getCurrentLevel() -> TSAlertLevel
    /// 是否允许弹窗显示
    func isShowAlert() -> Bool
}


struct TSAlertManagerTools {
    static var shared = TSAlertManagerTools()
    
    // 当前页面是否允许弹窗
    var isAllowAlert:Bool = false {
        didSet {
            if isAllowAlert == true {
                self.openCurrentView()
            }
        }
    }
    
    private var popViews :[TSAlertProtocol] = []
    private var currentObj:TSAlertProtocol?
}

extension TSAlertManagerTools {
    mutating func addNewAlertView(_ view:TSAlertProtocol) {
        // 添加目标View
        self.addPopView(view)
        
        self.openLastAlertView(view)
    }
    //  移除当前使用view
    mutating func removeUseAlertView(_ view:TSAlertProtocol) {
        // 移除目标view
        self.removePopView(view)
        currentObj = nil
        self.openLastAlertView(self.popViews.first)
    }
    
    // 移除所有view
    mutating func  removeAllAlertView() {
        currentObj?.dismiss(commotion: nil)
        currentObj = nil
        self.popViews.removeAll()
    }
    
    // 打开当前view
    mutating func openCurrentView() {
        self.openLastAlertView(self.popViews.first)
    }
    
    // 更新当前选中view
    private mutating func openLastAlertView(_ view:TSAlertProtocol?) {
        // 该弹窗不能弹出
        if view?.isShowAlert() == false && isAllowAlert == false {
            return
        }
        // 当前试图不存在，打开下一个
        if currentObj == nil {
            currentObj = view
            currentObj?.showAnimation(true)
        }else{ // 当前试图被 hidden ，打开hidden
            if currentObj?.getCurrentHidden() == true {
                currentObj?.showAnimation(false)
            }
        }
    }
}

// 更新pop队列
extension TSAlertManagerTools  {
    
    private mutating func addPopView(_ view:TSAlertProtocol) {
        if popViews.count < 1 {
            self.popViews.append(view)
        }else{
            for i in 0..<popViews.count {
                let obj = popViews[i]
                if view.getCurrentLevel().rawValue > obj.getCurrentLevel().rawValue  {
                    self.popViews.insert(view, at: i)
                    break
                }else{
                    // 查找到最后一个，直接添加
                    if i == popViews.count - 1 {
                        self.popViews.append(view)
                    }
                }
            }
        }
    }
    
    private mutating func removePopView(_ view:TSAlertProtocol) {
        
        guard let firstIdx = popViews.firstIndex(where: { $0.getAddress() == view.getAddress() }) else { return  }
        self.popViews.remove(at: firstIdx)
    }
}

// MARK: 打开新手引导的弹窗
extension TSAlertManagerTools {
//    func openNewGuideAlertView(_ dType : TSDeviceType, _ completion:CommonEmptyBlock? = nil) {
//        let isSuportCallBluetooth = TSDeviceSupportTools.isSuportCallBluetooth(dType)
//        ///支持蓝牙通话-
//        if isSuportCallBluetooth {
//            self.openCallAlertView {
//                completion?()
//            }
//        }
//        else {
//            ///不支持蓝牙通话-- 天气设置
//            self.openOnlyWeatherAlert {
//                completion?()
//            }
//
//        }
//    }
}

// 新手引导弹窗
extension TSAlertManagerTools {
    private func openCallAlertView(_ completion:CommonEmptyBlock? = nil) {
        // 打开通话蓝牙弹窗
//        TSDeviceCallTools.shared.getCallBleStatus { success in
//            // 通讯录权限引导
//            TSDeviceCallTools.shared.openGuideContasts { finish in
//                // 天气权限引导
//                TSWeatherTools.shared.openWeartherSwitch { finish in
//                    completion?()
//                }
//            }
//        }
    }
    
    private func openOnlyWeatherAlert(_ completion:CommonEmptyBlock? = nil) {

//        // 天气权限引导
//        TSWeatherTools.shared.openWeartherSwitch { _ in
//            completion?()
//        }
    }

}
