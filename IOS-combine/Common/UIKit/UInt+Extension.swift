//
//  UInt+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

extension UInt64 {
    var toDateTime: Date {
        return Date(timeIntervalSince1970: Double(self/1000))
    }
}
