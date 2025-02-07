//
//  ZHBaseBottomPopView.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/26.
//

import UIKit

enum ZHPickerAlertType : String{
    case none
    // 数字类型
    case steps = "steps"
    case kcal  = "kcal"
    case min   = "min"
    case second = "second"
    case bpm   = "bpm"
    case warnbpm   = "warnbpm"
    // 非数字类型
    case time  = "time"
}

class ZHBaseBottomAlertView: BaseView {
    
    private let bgview = UIView.init()
    var contentView : UIView = UIView.init()
    var bgColor:UIColor = .color000000 {
        didSet {
            bgview.backgroundColor = bgColor
        }
    }
    // 是否点击确认自动消失
    var isAutoHidden : Bool = true
    
    override func setupUI() {
        self.frame = UIScreen.main.bounds
        
        bgview.backgroundColor = UIColor.color000000.withAlphaComponent(0.7)
        addSubview(bgview)
        bgview.snp.makeConstraints {
            $0.bottom.top.leading.trailing.equalToSuperview()
        }
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        contentView.backgroundColor = .color1B1C1E
        addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-bottomSafeHeight - 10)
        }
    }
}




class ZHCannelAndConfirmView: BaseView {
    
    private var _rightBlock:CommonEmptyBlock?
    private var _leftBlock : CommonEmptyBlock?
    private var _confirmBtn : UIButton?
    private var _cannelBtn : UIButton?
    
    convenience init(rightText : String = "确定"  , leftText : String = "取消" , rightBlock:CommonEmptyBlock? , leftBlock:CommonEmptyBlock?) {
        self.init()
        _cannelBtn?.setTitle(leftText, for: .normal)
        _confirmBtn?.setTitle(rightText, for: .normal)
        _rightBlock = rightBlock
        _leftBlock = leftBlock
    }
    
    override func setupUI() {
        let confirmBtn = UIButton(title: "",
                                  textColor: UIColor.color1FAD4F,
                                  font: .medium18(),
                                 target: self,
                                 selector: #selector(finishAction))
        addSubview(confirmBtn)
        
        confirmBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview()
        }
        _confirmBtn = confirmBtn
        
        let cannelBtn = UIButton(title: "",
                                 textColor: UIColor.color959495,
                                 font: .medium18(),
                                 target: self,
                                 selector: #selector(cannelAction))
        addSubview(cannelBtn)
        _cannelBtn = cannelBtn
        
        cannelBtn.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(confirmBtn.snp.width)
            $0.trailing.equalTo(confirmBtn.snp.leading)
        }
        
        let centerLineView = UIView.init()
        centerLineView.backgroundColor = UIColor.color333333
        addSubview(centerLineView)
        
        centerLineView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(1)
            $0.centerX.equalToSuperview()
        }
        
        let topLineView = UIView.init()
        topLineView.backgroundColor = UIColor.color333333
        addSubview(topLineView)
        
        topLineView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    @objc func finishAction() {
        _rightBlock?()
    }
    
    @objc func cannelAction() {
       _leftBlock?()
    }
}
