//
//  ContactService.swift
//  IOS-combine
//
//  Created by usama farooq on 06/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

class ContactService: BaseDataStore {
    
    let translator: ObjectTranslator
    
    init(service: Service, translator: ObjectTranslator = ObjectTranslation()) {
        self.translator = translator
        super.init(service: service)
    }
}

extension ContactService {
    func fetchContacts(complition: @escaping AllUserComplition) {
        let request = AllUserRequest()
        service.get(request: request) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let data):
                self.translate(data: data, complition: complition)
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    private func translate(data: Data, complition: AllUserComplition) {
        do {
            let respone: AllUsersResponse = try translator.decodeObject(data: data)
            complition(.success(respone))
        } catch {
            complition(.failure(error))
        }
    }
}
