//
//  TLOCPPlayLoadEncodeType.swift
//  TLOCP
//
//  Created by t_t on 2023/8/16.
//

import Foundation

enum TLOCPPlayLoadEncodeType {
    case data
    case json
    init?(data: UInt8) {
        if data & 0b00000100 == 0b00000100 {
            self = .json
        }else{
            self = .data
        }
    }
}
