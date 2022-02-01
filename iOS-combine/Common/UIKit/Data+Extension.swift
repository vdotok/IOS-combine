//
//  Data+Extension.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:UInt64 {
        return UInt64((self.timeIntervalSince1970 * 1000))
    }
    
    var toTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "h:mm"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: self)
    }
    
}
