//
//  TLOCPPayLoadType.swift
//  TLOCP
//
//  Created by t_t on 2023/8/16.
//

import Foundation

enum TLOCPPayloadPageType {
    case none
    case header
    case body
    case footer
    
    init?(data: UInt8) {
        
        if data & 0b00000011 == 0b00000000 {
            self = .none
        }else
        if data & 0b00000011 == 0b00000001 {
            self = .header
        }else
        if data & 0b00000011 == 0b00000010 {
            self = .body
        }else
        if data & 0b00000011 == 0b00000011 {
            self = .footer
        }else{
            return nil
        }
    }
}

enum TLOCPPayloadType: UInt8 {
    case noneAndBin = 0b0000000
    case headAndBin = 0b0000001
    case bodyAndBin = 0b0000010
    case footAndBin = 0b0000011
    case noneAndJson = 0b0000100
    case headAndJson = 0b0000101
    case bodyAndJson = 0b0000110
    case footAndJson = 0b0000111
}
