//
//  SJ.swift
//  LensMoo
//
//  Created by tanghan on 2021/11/1.
//

import Foundation
import SVProgressHUD

struct SJHud {
    static func showText(status : String?) {
        if SVProgressHUD.isVisible() == false {
            SVProgressHUD.showInfo(withStatus: status)
        }
        
    }
    
    static func showRemind(status: String?, delay: Double = 2) {
        SVProgressHUD.showInfo(withStatus: status)
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
    static func showText(status: String?, delay: Double = 2) {
        SVProgressHUD.show(withStatus: status)
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
    static func showLoading(text :String?) {
        SVProgressHUD.show(withStatus: text)
    }

    static func dismiss(_ text : String? = nil) {
        SVProgressHUD.dismiss()
        if (text?.count ?? 0) > 0  {
            SVProgressHUD.showInfo(withStatus: text)
        }
    }
}
