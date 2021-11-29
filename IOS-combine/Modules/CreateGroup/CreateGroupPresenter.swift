//
//  CreateGroupPresenter.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import iOSSDKConnect

final class CreateGroupPresenter {

    // MARK: - Private properties -

    private unowned let view: CreateGroupViewInterface
    private let interactor: CreateGroupInteractorInterface
    private let wireframe: CreateGroupWireframeInterface
    var output: CreateGroupOutput?
    var selectedItems: [Int] = []
    var contacts: [User] = []
    var isSearching: Bool = false
    var searchContacts: [User] = []
    var client: ChatClient
    

    // MARK: - Lifecycle -

    init(
        view: CreateGroupViewInterface,
        interactor: CreateGroupInteractorInterface,
        wireframe: CreateGroupWireframeInterface,
        client: ChatClient
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.client = client
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
        case groupCreated(group: Group)
        case updateRow(index: Int)
        case failure(message: String)
    }
}

// MARK: - Extensions -

extension CreateGroupPresenter {
    private func getUsers() {
        output?(.showProgress)
        interactor.fetchContacts()
    }
}

extension CreateGroupPresenter: CreateGroupPresenterInterface {

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
    
    func deleteUser(id: Int) {
        let index = selectedItems.firstIndex(of: id)
        selectedItems.remove(at: index!)
    }
    
    func addUser(userId: Int, row: Int) {
        if selectedItems.contains(userId) {
           deleteUser(id: userId)
            output?(.updateRow(index: row))
        } else {
            if selectedItems.count == 4 {
                output?(.failure(message: "You can only select 4 participants"))
                return
                
            }
            selectedItems.append(userId)
            output?(.updateRow(index: row))
        }
    }
    
    func check(id: Int) -> Bool {
        selectedItems.contains(id) ? false : true
    }
    
    func createGroup(with title: String) {
        output?(.showProgress)
        interactor.CreateGroup(with: title, participants: selectedItems, autoCreated: 0)
    }
    
    func createGroup(with user: User) {
        guard let myUser = VDOTOKObject<UserResponse>().getData() else {return}
        let groupName: String = myUser.fullName! + " - " + user.fullName
        interactor.CreateGroup(with: groupName, participants: [user.userID], autoCreated: 1)
        output?(.showProgress)
    }
    func moveToChat(group: Group) {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        wireframe.moveToChat(with: client, group: group, user: user)
    }
    
}


extension CreateGroupPresenter: CreateGroupInteractorToPresenter {
    
    func didFetchContacts(users: [User]) {
        output?(.hideProgress)
        contacts = users
        searchContacts = contacts
        output?(.reload)
    }

    func didFailedToFetch(with error: String) {
        output?(.hideProgress)
        output?(.failure(message: error))
    }
    
    func groupCreated(with group: Group) {
        output?(.hideProgress)
        output?(.groupCreated(group: group))
    }
    
    func groupCreatedFailed(with message: String) {
        output?(.hideProgress)
        output?(.failure(message: message))
    }
    
}
