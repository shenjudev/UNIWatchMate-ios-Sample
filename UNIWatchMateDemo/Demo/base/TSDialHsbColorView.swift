//
//  TSDialHsbColorView.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/12/28.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import UIKit

class TSDialHsbColorView: ZHBaseBottomAlertView{
    lazy var dailIcon:UIImageView = UIImageView.init()
    lazy var timeIcon:UIImageView = UIImageView.init()
    lazy var videoPreviewView = TSLoopVideoView()
    
    var fontColor : UIColor? {
        didSet {
            timeIcon.image = timeIcon.image ?? UIImage().withTintColor(fontColor ?? UIColor())
        }
    }
    
    var timeChangeBlock:((UIColor?) -> ())?
    
    var colorChangeBlock:((UIColor?) -> ())?
    
    func loadVideoIfNeed(model: TSWatchDailModel?) {
        guard let model = model,
              model.isVideo,
              let _ = try? Data(contentsOf: .init(fileURLWithPath: model.filePath)) else {
            self.videoPreviewView.isHidden = true
            self.dailIcon.isHidden = false
            self.videoPreviewView.stop()
            return
        }
        self.videoPreviewView.isHidden = false
        self.dailIcon.isHidden = true
        
        self.videoPreviewView.setupVideoPlayer(url: .init(fileURLWithPath: model.filePath))
    }
    
    override func setupUI() {
        super.setupUI()
        
        //self.bgColor = UIColor.color000000
        let bottomView = ZHCannelAndConfirmView { [weak self] in
            self?.timeChangeBlock?(self?.fontColor)
            self?.removeFromSuperview()
        } leftBlock: { [weak self] in
            self?.timeChangeBlock?(nil)
            self?.removeFromSuperview()
        }

        contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        let hsbView = EFHSBView.init(frame: CGRect.init(x: 0, y: 0, width: 250, height: 250))
        hsbView.delegate = self
        contentView.addSubview(hsbView)
        hsbView.snp.makeConstraints {
            $0.bottom.equalTo(bottomView.snp.top).offset(-17)
            $0.width.height.equalTo(250)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(15)
        }
        
        dailIcon.borderWidth = 1
        dailIcon.borderColor = .colorFFFFFF
        
        self.contentView.layoutIfNeeded()
        

        var width = 120.0
        var height = 140.0
        var cornerRadius = 15.0
        var isSquare = true

            width = 120.0
            height = 140.0
            cornerRadius = 15.0

        addSubview(videoPreviewView)
        addSubview(dailIcon)
        dailIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            if isSquare {
                $0.bottom.equalTo(contentView.snp.top).offset(-58)
            }else{
                $0.bottom.equalTo(contentView.snp.top).offset(-58)
            }
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        videoPreviewView.snp.makeConstraints { make in
            make.edges.equalTo(dailIcon)
        }
        dailIcon.cornerRadius = cornerRadius
        videoPreviewView.cornerRadius = cornerRadius

        timeIcon.backgroundColor = .clear
        addSubview(timeIcon)
        timeIcon.cornerRadius = cornerRadius
        timeIcon.snp.makeConstraints {
            $0.edges.equalTo(dailIcon)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

extension TSDialHsbColorView:EFColorViewDelegate {
    func colorView(colorView: EFColorView, didChangeColor color: UIColor) {
        self.fontColor = color
        if self.colorChangeBlock != nil {
            self.colorChangeBlock!(color)
        }
        
    }
}

