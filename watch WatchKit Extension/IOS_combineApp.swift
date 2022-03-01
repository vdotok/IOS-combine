//
//  IOS_combineApp.swift
//  watch WatchKit Extension
//
//  Created by usama farooq on 28/02/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import SwiftUI

@main
struct IOS_combineApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
