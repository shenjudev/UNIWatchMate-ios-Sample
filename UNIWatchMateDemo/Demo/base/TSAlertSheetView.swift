//
//  TSAlertSheetView.swift
//  OraimoHealth
//
//  Created by Eleven on 2021/11/26.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import Foundation
import UIKit

@objcMembers
class TSAlertSheetView: UIView ,TSAlertProtocol {
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var okItem: UIButton!
    
    @IBOutlet weak var titleLbl: UILabel!
        
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var centerLineView: UIView!
    
    
    typealias Closure = () -> Void
    // 是否可以点击移除弹窗
    var isClickRemove : Bool = false  {
        didSet {
            self.addRemoveTap()
        }
    }
    
    // 弹窗是否可以直接打开
    var isShow:Bool = true
    // 不添加到弹窗列表
    var isNoAddAlertList:Bool = false
    /// 取消回调
    var cancelClosure: Closure?
    /// 确定回调
    var okClosure: Closure?
}


// MARK: - LifeCycle

extension TSAlertSheetView {
    override func awakeFromNib() {
        super.awakeFromNib()

        width = screenWidth

        height = screenHeight
        
        leftBtn.titleLabel?.numberOfLines = 0
        rightBtn.titleLabel?.numberOfLines = 0

//        configClick()
    }
    
    private func addRemoveTap() {
        self.addTapGeseTure(self, #selector(hideAnimation))
    }
}
// MARK: - Click

extension TSAlertSheetView {
    @IBAction func leftBtnAction(_ sender: Any) {
        
        self.hide()

        self.cancelClosure?()
    }
    
    @IBAction func rightBtnAction(_ sender: Any) {

            self.hide()

            self.okClosure?()
    }
   
}

// MARK: - Method
extension TSAlertSheetView {
    
    
    func show(icon: UIImage? = nil, title: NSAttributedString, alignment: NSTextAlignment = .center, leftTitle: String? = nil,rightTitle: String? = nil, cancelClosure: Closure? = nil, rightClosure:Closure? = nil) {
        
        iconView.image = icon
        
        iconView.isHidden = icon == nil
        
//        contentConstraint.constant = icon == nil ? 24 : 114
        titleLbl.snp.updateConstraints {
            $0.top.equalToSuperview().offset(icon == nil ? 24 : 114)
        }
        titleLbl.attributedText = title
        
        titleLbl.textAlignment = alignment
        
        leftBtn.titleForNormal = (leftTitle?.count ?? 0) > 0 ? leftTitle : "取消"
        rightBtn.titleForNormal = (rightTitle?.count ?? 0) > 0 ? rightTitle : "已了解"
        
        self.okClosure = rightClosure
        self.cancelClosure = cancelClosure
        if isNoAddAlertList {
            self.showAnimation(true)
        }else{
            TSAlertManagerTools.shared.addNewAlertView(self)
        }
       
        //showAnimation()

    }
    
    func showCenterItem(icon: UIImage? = nil, title: NSAttributedString, alignment: NSTextAlignment = .center ,rightTitle: String? = nil, rightClosure:Closure? = nil) {
        
        iconView.image = icon
        
        iconView.isHidden = icon == nil
        
        titleLbl.snp.updateConstraints {
            $0.top.equalToSuperview().offset(icon == nil ? 24 : 114)
        }
        titleLbl.attributedText = title
        
        titleLbl.textAlignment = alignment
        
        leftBtn.isHidden = true
        rightBtn.isHidden = true
        centerLineView.isHidden = true
        
        okItem.isHidden = false
        
        okItem.titleForNormal = (rightTitle?.count ?? 0) > 0 ? rightTitle : "已了解"
        
        self.okClosure = rightClosure

        if isNoAddAlertList {
            self.showAnimation(true)
        }else{
            TSAlertManagerTools.shared.addNewAlertView(self)
        }
    }
    
   @objc func hide() {
       TSAlertManagerTools.shared.removeUseAlertView(self)
        self.removeFromSuperview()
    }
    
    func dismiss(commotion: CommonEmptyBlock?) {
        self.removeFromSuperview()
    }
    
    func getAddress() -> String {
        return  String(format: "%p", self)
    }
    
    func getCurrentHidden() -> Bool {
        return self.isHidden
    }
    
    func getCurrentLevel() -> TSAlertLevel {
        return .None
    }
    
    func isShowAlert() -> Bool {
        return isShow
    }
    
    func showAnimation(_ isCreate: Bool) {
        let y = effectView.y
        
        effectView.y = screenHeight
        
        if isCreate {
            UIApplication.shared.keyWindow?.addSubview(self)
        }else{
            self.isHidden = false
        }
        
        UIView.animate(withDuration: 0.35) {[weak self] in
            
            guard let self = self else { return }
            
            self.effectView.y = y
        }
    }
    
   @objc fileprivate func hideAnimation() {
        
        let y = effectView.y
        
        UIView.animate(withDuration: 0.35, animations: {[weak self] in
            
            guard let self = self else { return }
            
            self.effectView.y = screenHeight
            
        }) { [weak self] _ in
            
            guard let self = self else { return }
            TSAlertManagerTools.shared.removeUseAlertView(self)
            self.removeFromSuperview()
            
            self.effectView.y = y
        }
    }
}
