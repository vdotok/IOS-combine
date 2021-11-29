//
//  LoginService.swift
//  IOS-combine
//
//  Created by usama farooq on 06/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation


class LoginService: BaseDataStore {
    
    
    let translator: ObjectTranslator
    
    init(service: Service, translator: ObjectTranslator = ObjectTranslation()) {
        self.translator = translator
        super.init(service: service)
    }
    
    
    func loginWith(email: String, password: String, complition: @escaping loginComplition) {
        let request = LoginRequest(email: email, password: password)
        service.post(request: request) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                self.translate(data: data, complition: complition)
            case .failure(let error):
                complition(.failure(error))
                
            }
            
        }
    }
    
    private func translate(data: Data, complition: loginComplition) {
        do {
            let response: UserResponse = try translator.decodeObject(data: data)
            switch response.status {
            case 200:
                VDOTOKObject<UserResponse>().setData(response)
                VDOTOKObject<String>().setToken(response.authToken)
            default:
                break
            }
            complition(.success(response))
            
        }
        catch {
            complition(.failure(error))
        }
    }
}
