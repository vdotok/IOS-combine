//
//  CreateGroupInteractor.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation

typealias GroupComplition = ((Result<CreateGroupResponse, Error>) -> Void)

final class CreateGroupInteractor {
    
    let service = ContactService(service: NetworkService())
    let createGroupService = CreateGroupService(service: NetworkService())
    weak var presenter: CreateGroupInteractorToPresenter?
}

// MARK: - Extensions -

extension CreateGroupInteractor: CreateGroupInteractorInterface {
    func fetchContacts() {
        service.fetchContacts { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    switch response.status {
                    case 200:
                        self.presenter?.didFetchContacts(users: response.users)
                    default:
                        self.presenter?.didFailedToFetch(with: response.message)
                    }
                case .failure(let error):
                    self.presenter?.didFailedToFetch(with: error.localizedDescription)
                }
            }
            
        }
    }
    
    func CreateGroup(with title: String, participants: [Int], autoCreated: Int) {
        createGroupService.createGroup(groupName: title, participants: participants, autoCreated: autoCreated) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let response):
                switch response.status {
                case 200:
                    guard let group = response.group else {return}
                    self.presenter?.groupCreated(with: group)
                default:
                    self.presenter?.groupCreatedFailed(with: response.message)
                }
            case .failure(let error):
                self.presenter?.groupCreatedFailed(with: error.localizedDescription)
            }
        }
    }
    
    

}
