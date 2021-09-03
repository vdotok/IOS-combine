//
//  CreateGroupInterfaces.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect

typealias CreateGroupOutput = (CreateGroupPresenter.Output) -> Void


protocol CreateGroupWireframeInterface: WireframeInterface {
    
    func moveToChat(with client: ChatClient, group: Group, user: UserResponse)
}

protocol CreateGroupViewInterface: ViewInterface {
}

protocol CreateGroupPresenterInterface: PresenterInterface {
    var output: CreateGroupOutput? { get set }
    var selectedItems: [Int] {get set}
    var contacts: [User] {get set}
    var isSearching: Bool {get set}
    var searchContacts: [User] {get set}
    var client: ChatClient {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func rowsCount() -> Int
    func viewModelItem(row: Int) -> User
    func filterGroups(with text: String)
    func deleteUser(id: Int)
    func addUser(userId:Int, row: Int)
    func check(id: Int) -> Bool
    func createGroup(with title: String)
    func createGroup(with user: User)
    func moveToChat(group: Group)
}

protocol CreateGroupInteractorInterface: InteractorInterface {
    func createGroup(with request: CreateGroupRequest, complition: @escaping GroupComplition)
    func fetchUsers(complition: @escaping AllUserComplition)
}