//
//  SJ2WatchHighSpeedModeSetTask.swift
//  SJWatchLib
//
//  Created by t_t on 2024/1/11.
//

import Foundation

class SJ2WatchHighSpeedModeModel: SJTLOCPWriteEnable {
    init(){}
    required init?(data: Data) {
        guard data.count == 1, data[0] == 1 else {return nil}
    }
    
    var toData: [Data] {
        return []
    }
    static var urnString: String {"1016"}
}

class SJ2WatchHighSpeedModeTask: SJ2BaseNodeTask<SJ2WatchHighSpeedModeModel> {
    override var desc: String {"进入高速传输模式"}
    
    override var timeout: Int {5}
}
