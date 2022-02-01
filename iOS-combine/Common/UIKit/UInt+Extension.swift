//
//  UInt+Extension.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 03/06/2021.
//

import Foundation

extension UInt64 {
    var toDateTime: Date {
        return Date(timeIntervalSince1970: Double(self/1000))
    }
}
