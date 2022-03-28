//
//  CallingManager.swift
//  IOS-combine
//
//  Created by usama farooq on 28/03/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming


class CallingManager {
    var vtokSdk: VTokSDK?
    
    init() {
        guard let user = VDOTOKObject<UserResponse>().getData(), let url = user.mediaServerMap?.completeAddress else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceID: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestID: getRequestId(),
                                    projectID: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: url, registerRequest: request, connectionDelegate: self)
    }
    
    private func getRequestId() -> String {
        let generatable = IdGenerator()
        guard let response = VDOTOKObject<UserResponse>().getData() else {return ""}
        let timestamp = NSDate().timeIntervalSince1970
        let myTimeInterval = TimeInterval(timestamp)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval)).stringValue()
        let tenantId = "12345"
        let token = generatable.getUUID(string: time + tenantId + response.refID!)
        return token
        
    }
}

extension CallingManager: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
     
        switch output {
        case .registered:
            print("registered")
        case .disconnected(let string):
            print("disconnected")
        case .sessionRequest(let vTokBaseSession):
            print(vTokBaseSession)
        }
    }
    
    
}
