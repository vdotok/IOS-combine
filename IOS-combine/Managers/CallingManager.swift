//
//  CallingManager.swift
//  IOS-combine
//
//  Created by usama farooq on 28/03/2022.
//  Copyright © 2022 VDOTOK. All rights reserved.
//

import Foundation
import iOSSDKStreaming

protocol CallingManagerDelegate: AnyObject {
    func didGenerate(output: SDKOutPut)
}


class CallingManager {
    var vtokSdk: VTokSDK?
    weak var delegate: CallingManagerDelegate?
    var vtokBaseSession: VTokBaseSession?
    var group: Group?
    var contacts: [User] = []
    
    init() {
 
    }
    
    func connect(delegate: CallingManagerDelegate) {
        self.delegate = delegate
        guard let user = VDOTOKObject<UserResponse>().getData(), let url = user.mediaServerMap?.completeAddress else {return}
        let request = RegisterRequest(type: Constants.Request,
                                      requestType: Constants.Register,
                                      referenceID: user.refID!,
                                      authorizationToken: user.authorizationToken!,
                                      requestID: getRequestId(),
                                    projectID: AuthenticationConstants.PROJECTID)
        self.vtokSdk = VTokSDK(url: url, registerRequest: request, connectionDelegate: self, peerName: user.fullName!)
    }
    
    func makeCall() {
        
    }
   
}

extension CallingManager: SDKConnectionDelegate {
    func didGenerate(output: SDKOutPut) {
        switch output {
        case .registered:
            break
        case .disconnected(_):
            break
        case .sessionRequest(let vTokBaseSession):
            self.vtokBaseSession = vTokBaseSession
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.delegate?.didGenerate(output: output)
        }
        
    }
    
    
}

extension CallingManager {
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
