//
//  TSWatchDailModel.swift
//  OraimoHealth
//
//  Created by Eleven on 2021/12/6.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import Foundation
import UIKit

//表盘模型，根据供应商微调
class TSWatchDailModel {
    var filePath: String = "" //必传
    var timeLocation: Int = 0
    var textColorType: Int = 0
    
    var dailId: String = "" //必传
    
    var bgImage: UIImage?
    // 文字图
    var textImage: UIImage?
    // 文字颜色
    var textColor: UIColor?
    // 表盘规则(ZH 18需要)
    var dailRule = false
    
    //自定义表盘预览图(UTE，最终预览图包含所有元素显示)
    var bgPreview: UIImage?
    //自定义表盘bin数据(UTE，发送到设备)
    var customBinData : Data?
    //是否是视频表盘
    var isVideo = false
    init() {

    }
    
    //ZH 壁纸表盘
    init( dailId: String, photo bgImage: UIImage?, textImage: UIImage?, textColor: UIColor?, filePath: String) {
        self.dailId = dailId
        self.bgImage = bgImage
        self.textImage = textImage
        self.textColor = textColor
        self.filePath = filePath
    }
    
    //ZH 云表盘
    init(dailId: String, filePath: String) {
        self.dailId = dailId
        self.filePath = filePath
    }
}
extension TSWatchDailModel {
    func toWmModel() -> WMCustomDialModel {
     let model = WMCustomDialModel()
        model.dialId = self.dailId
        model.backgroundImage = self.bgImage
        model.textImage = self.textImage
        model.textColor = self.textColor
        model.type = self.isVideo ? .video : .image
        model.videoUrl = URL(fileURLWithPath: self.filePath)
        var param = [String: Any]()
        if self.timeLocation == 0 {
             param["time_style"] = "custom_dial_top_left"
        }else if self.timeLocation == 1 {
            param["time_style"] = "custom_dial_bottom_left"
        }else if self.timeLocation == 2 {
            param["time_style"] = "custom_dial_top_right"
        }else if self.timeLocation == 3 {
            param["time_style"] = "custom_dial_bottom_right"
        }
        model.param = param
        return model
    }
}
