//
//  BroadcastData.swift
//  IOS-combine
//
//  Created by usama farooq on 11/10/2021.
//

import Foundation
import iOSSDKStreaming

struct BroadcastData:Codable {
    var broadcastType: BroadcastType
    var broadcastOptions: BroadcastOptions
    var broadcastGroupID: String?
    
}

struct ScreenShareAudioState: Codable {
    let screenShareAudio: ScreenShareBytes
}

struct ScreenShareScreenState: Codable {
    let screenShareScreen: ScreenShareBytes
}
