//
//  MTError.swift
//  SHWatchLib
//
//  Created by t_t on 2023/9/5.
//

import Foundation

enum MTError: Error {
    case other
    case poweredOff
    case bleServiceNotFound
    case disconnect
    case timeout(String)
    case commandFail(String)
    case urlError
    case filesDifferent
    case busy
    case notEnoughSpace
    case dialMax
    case lowBattery
    case cancel
    case abnormalDataStructure
    case commandRepeat
    case notSupport
    case customDialFail
}

extension Error where Self == MTError {
    static func mt(_ error: MTError) -> Error {
        return error
    }
}
