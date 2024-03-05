//
//  BaseView.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/29.
//

import Foundation
import UIKit
class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }

}
