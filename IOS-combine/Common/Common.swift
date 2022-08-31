//
//  Common.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//
import AVFoundation
import UIKit

class Common {
    static public func isAuthorized(with complition: ((Bool) -> ()))  {
        if AVCaptureDevice.authorizationStatus(for: .audio) != .authorized {
            complition(false)
            return
        } else if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
        complition(false)
            return
        }
        complition(true)
        return

    }
}
