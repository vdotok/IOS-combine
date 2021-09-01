//
//  UInt+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//

import Foundation

extension UInt64 {
    var toDateTime: Date {
        return Date(timeIntervalSince1970: Double(self/1000))
    }
}
