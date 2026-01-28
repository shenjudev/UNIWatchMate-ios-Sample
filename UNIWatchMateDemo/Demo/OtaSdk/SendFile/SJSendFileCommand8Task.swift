//
//  SJSendFileCommand5Task.swift
//  WatchLib
//
//  Created by t_t on 2023/3/1.
//

import Foundation
import RxCocoa
import RxSwift
import PromiseKit

class SJSendFileCommand8Task: MTBleOnlySetTask<Bool, Bool> {
    override var sceneId: Int {0x0e}
    override var commandId: Int {0x0008}
    override var desc: String {"0e 0008"}
  
}
