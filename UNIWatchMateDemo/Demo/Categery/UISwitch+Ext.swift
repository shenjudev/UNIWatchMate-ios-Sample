//
//  UISwitch+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/12/14.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import UIKit
import MapKit

extension UISwitch {
    convenience init(onImg : UIImage? = UIImage(named: "ic_switch_on") ,
                     offimg : UIImage? = UIImage(named: "ic_switch_off"),
                     target:Any?,
                     action:Selector) {
        self.init(frame: .zero)
        self.onImage = onImg
        self.offImage = offimg
        self.addTarget(target, action: action, for: .valueChanged)
    }
}

//extension UITableView {
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//       // self.next?.touchesBegan(touches, with: event)
//        super.touchesBegan(touches, with: event)
//    }
//    
//    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//      //  self.next?.touchesMoved(touches, with: event)
//        super.touchesMoved(touches, with: event)
//    }
//    
//    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//      //  self.next?.touchesEnded(touches, with: event)
//        super.touchesEnded(touches, with: event)
//    }
//}
