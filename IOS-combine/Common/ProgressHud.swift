//
//  ProgressHud.swift
//  IOS-combine
//
//  Created by usama farooq on 31/08/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import KRProgressHUD

class ProgressHud {
    
    static let shared: ProgressHud = ProgressHud()
     private init() {}
    let windowScene = UIApplication.shared
        .windows[0].windowScene
    var popupWindow: UIWindow?
    let viewController = UIViewController()
    
    static func showError(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func show(viewController: UIViewController = UIViewController()) {
        KRProgressHUD.show()
    }
    
    static func hide() {
        DispatchQueue.main.async {
            KRProgressHUD.dismiss()
        }
       
    }
    
    static func showMessage(text: String) {
        KRProgressHUD.showMessage(text)
    }
    
    func alertForPermission() {
        let title = "To place calls, VDOTOK needs access to your iPhone's microphone and camara. Tap Settings and turn on microphone and camera."
       let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
       
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) {  [weak self]_ in
            guard let self = self else {return}
            self.popupWindow = nil
        })
       alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { [weak self] (alert) -> Void in
           guard let self = self else {return}
           if let appSettings = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) {
               if UIApplication.shared.canOpenURL(appSettings) {
                   UIApplication.shared.open(appSettings)
               }
           }
           self.popupWindow = nil
       })
        if let windowScene = windowScene  {
            popupWindow = UIWindow(windowScene: windowScene)
            popupWindow?.frame = UIScreen.main.bounds
            popupWindow?.backgroundColor = .clear
            popupWindow?.windowLevel = UIWindow.Level.statusBar + 1
            popupWindow?.rootViewController = self.viewController
            popupWindow?.makeKeyAndVisible()
            popupWindow?.rootViewController?.present(alert, animated: true)
        }
       
   }
}
