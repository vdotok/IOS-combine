//
//  CreateGroupService.swift
//  IOS-combine
//
//  Created by usama farooq on 07/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation

class CreateGroupService: BaseDataStore {
    
    let translator: ObjectTranslator
    init(service: Service, translator: ObjectTranslator = ObjectTranslation() ) {
        self.translator = translator
        super.init(service: service)
    }
}

extension CreateGroupService {
    func createGroup(groupName: String, participants: [Int], autoCreated: Int, complition: @escaping ContactComplition) {
        let request = CreateGroupRequest(groupTitle: groupName, participants: participants, autoCreated: autoCreated)
        service.post(request: request) { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main .async {
                switch result {
                case .success(let data):
                    self.translate(data: data, complition: complition)
                case .failure(let error):
                    complition(.failure(error))
                }
            }
         
        }
    }
    
    private func translate(data: Data, complition: @escaping ContactComplition) {
        do {
            let response: CreateGroupResponse = try translator.decodeObject(data: data)
            complition(.success(response))
        } catch {
            complition(.failure(error))
        }
    }
}
