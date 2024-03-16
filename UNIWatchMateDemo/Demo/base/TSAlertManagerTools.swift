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

    /// Open a new attempt
    func showAnimation(_ isCreate:Bool)
    // Popup disappears
    func dismiss(commotion:CommonEmptyBlock?)
    // Get memory address
    func getAddress() -> String
    // Get try to hide or not
    func getCurrentHidden() -> Bool
    // Gets the level of the current popup
    func getCurrentLevel() -> TSAlertLevel
    /// Whether to allow popup display
    func isShowAlert() -> Bool
}


struct TSAlertManagerTools {
    static var shared = TSAlertManagerTools()
    
    // Whether pop-ups are allowed on the current page
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
        // Add target View
        self.addPopView(view)
        
        self.openLastAlertView(view)
    }
    //  Remove the view currently in use
    mutating func removeUseAlertView(_ view:TSAlertProtocol) {
        // Remove target view
        self.removePopView(view)
        currentObj = nil
        self.openLastAlertView(self.popViews.first)
    }
    
    // Remove all Views
    mutating func  removeAllAlertView() {
        currentObj?.dismiss(commotion: nil)
        currentObj = nil
        self.popViews.removeAll()
    }
    
    // Open current view
    mutating func openCurrentView() {
        self.openLastAlertView(self.popViews.first)
    }
    
    // Update the currently selected view
    private mutating func openLastAlertView(_ view:TSAlertProtocol?) {
        // The popup window cannot pop up
        if view?.isShowAlert() == false && isAllowAlert == false {
            return
        }
        // Current attempt does not exist, open the next one
        if currentObj == nil {
            currentObj = view
            currentObj?.showAnimation(true)
        }else{ // Currently trying to be hidden, open hidden
            if currentObj?.getCurrentHidden() == true {
                currentObj?.showAnimation(false)
            }
        }
    }
}

// Update pop queue
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
                    // Find the last one, just add it
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

// MARK: Open the newbie guided popup window
extension TSAlertManagerTools {
//    func openNewGuideAlertView(_ dType : TSDeviceType, _ completion:CommonEmptyBlock? = nil) {
//        let isSuportCallBluetooth = TSDeviceSupportTools.isSuportCallBluetooth(dType)
//        ///Support Bluetooth call -
//        if isSuportCallBluetooth {
//            self.openCallAlertView {
//                completion?()
//            }
//        }
//        else {
//            ///Bluetooth calls are not supported - weather Settings
//            self.openOnlyWeatherAlert {
//                completion?()
//            }
//
//        }
//    }
}

// Novice pilot window
extension TSAlertManagerTools {
    private func openCallAlertView(_ completion:CommonEmptyBlock? = nil) {
        // Open the call Bluetooth pop-up window
//        TSDeviceCallTools.shared.getCallBleStatus { success in
//            // Address book permission bootstrap
//            TSDeviceCallTools.shared.openGuideContasts { finish in
//                // Weather authority guidance
//                TSWeatherTools.shared.openWeartherSwitch { finish in
//                    completion?()
//                }
//            }
//        }
    }
    
    private func openOnlyWeatherAlert(_ completion:CommonEmptyBlock? = nil) {

//        // Weather authority guidance
//        TSWeatherTools.shared.openWeartherSwitch { _ in
//            completion?()
//        }
    }

}
