//
//  BiuSJBaseView.swift
//  BiuFrame
//
//  Created by t_t on 2022/6/2.
//  Copyright © 2022 XASJ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class SJBaseView: UIView {
    public var disposeBag = DisposeBag()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setting()
        appendUI()
        layoutUI()
        actionsHandler()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        destroy()
    }
    @objc dynamic open func setting() {}
    @objc dynamic open func appendUI() {}
    @objc dynamic open func layoutUI() {}
    @objc dynamic open func actionsHandler() {}
    @objc dynamic open func destroy() {}

}

