//
//  ChannelService.swift
//  IOS-combine
//
//  Created by usama farooq on 08/09/2021.
//

import Foundation

class ChannelService: BaseDataStore {
    
    let translator: ObjectTranslator
    
    init(service: Service, translator: ObjectTranslator = ObjectTranslation()) {
        self.translator = translator
        super.init(service: service)
    }
}

extension ChannelService {
    func FetchChannels(complition: @escaping ChannelComplition)  {
        let request = AllGroupRequest()
        service.post(request: request) { [weak self] result in
            guard let self = self else {return }
            switch result {
            case .success(let data):
                self.translation(with: data, complitionHandler: complition)
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    private func translation(with data: Data, complitionHandler: ChannelComplition) {
        do {
            let response: GroupResponse = try translator.decodeObject(data: data)
            complitionHandler(.success(response))
        } catch {
            complitionHandler(.failure(error))
        }
    }
    
    
}
