//
//  ContactPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKConnect

final class ContactPresenter {

    // MARK: - Private properties -

    private unowned let view: ContactViewInterface
    var interactor: ContactInteractorInterface?
    private let wireframe: ContactWireframeInterface
    var contacts: [User] = []
    var searchContacts: [User] = []
    var isSearching: Bool = false
    var output: ContactOutput?
    var client: ChatClient?
    var streamingManager: StreamingMananger
    // MARK: - Lifecycle -

    init(
        view: ContactViewInterface,
        interactor: ContactInteractorInterface,
        wireframe: ContactWireframeInterface,
        client: ChatClient,
        streamingManager: StreamingMananger
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.client = client
        self.streamingManager = streamingManager
    }
    
    func viewModelDidLoad() {
        getUsers()
    }
    
    func viewModelWillAppear() {
        
    }
    
    enum Output {
        case reload
        case showProgress
        case hideProgress
        case failure(message: String)
        case groupCreated(group: Group, isExit: Bool)
        case alreadyCreated(message : String)
    }
}

// MARK: - Extensions -

extension ContactPresenter: ContactPresenterInterface {
  
    
    func rowsCount() -> Int {
        return isSearching ? searchContacts.count : contacts.count
    }
    
    func viewModelItem(row: Int) -> User {
        return isSearching ? searchContacts[row] : contacts[row]
    }
    
    func filterGroups(with text: String) {
        self.searchContacts = contacts.filter({$0.fullName.lowercased().prefix(text.count) == text.lowercased()})
        output?(.reload)
    }
    
    func createGroup(with user: User) {
        guard let myUser = VDOTOKObject<UserResponse>().getData() else {return}
        let groupName: String = myUser.fullName! + " - " + user.fullName
        output?(.showProgress)
        interactor?.createGroup(with: groupName, participants: [user.userID])
    }
    
    func navigate(to: ContactNavigationOptions, group: Group? = nil) {
        switch to {
        case .chat:
            guard let client = client,
                  let user = VDOTOKObject<UserResponse>().getData(),
                  let group = group
            else {return }
            wireframe.navigate(to: to, client: client, group: group , user: user)
        case .createGroup:
            guard let client = client
            else {return}
            wireframe.navigate(to: .createGroup, client: client, group: nil, user: nil)
        }

    }
    
}

extension ContactPresenter {
    func getUsers() {
        output?(.showProgress)
        interactor?.fetchAllUser()
    }
}


extension ContactPresenter: ContactInterectorToPresenter {

    func fetchUserSuccess(with users: [User]) {
        contacts = users
        searchContacts = users
        
        output?(.hideProgress)
        DispatchQueue.main.async { [weak self] in
            self?.output?(.reload)
        }
       
    }
    
    func fetchUserFailure(with error: String) {
        output?(.hideProgress)
        output?(.failure(message: error))
    }
    
    
    func didGroupCreated(with group: Group) {
        output?(.hideProgress)
        output?(.groupCreated(group: group, isExit: false))
    }
    
    func didfailedToCreate() {
        output?(.hideProgress)
        output?(.failure(message: "something went wrong"))
    }
    
    func alreadyExist(group: Group) {
        output?(.hideProgress)
        output?(.groupCreated(group: group, isExit: true))
    }
}
