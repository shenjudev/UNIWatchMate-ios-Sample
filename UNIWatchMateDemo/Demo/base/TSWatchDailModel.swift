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
    var filePath: String = "" //Must be published
    var timeLocation: Int = 0
    var textColorType: Int = 0
    
    var dailId: String = "" //Must be published
    
    var bgImage: UIImage?
    // Word graph
    var textImage: UIImage?
    // Text color
    var textColor: UIColor?
    // Dial rule
    var dailRule = false
    
    //Custom watch face preview diagram (UTE, final preview diagram with all elements displayed)
    var bgPreview: UIImage?
    //Custom dial bin data (UTE, sent to device)
    var customBinData : Data?
    //Whether it is a video dial
    var isVideo = false
    init() {

    }
    
    //ZH Wallpaper dial
    init( dailId: String, photo bgImage: UIImage?, textImage: UIImage?, textColor: UIColor?, filePath: String) {
        self.dailId = dailId
        self.bgImage = bgImage
        self.textImage = textImage
        self.textColor = textColor
        self.filePath = filePath
    }
    
    //ZH Cloud dial
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
