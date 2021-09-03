//
//  ContactInterfaces.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect

typealias ContactOutput = (ContactPresenter.Output) -> Void
typealias AllUserComplition = ((Result<AllUsersResponse, Error>) -> Void)

protocol ContactWireframeInterface: WireframeInterface {
    func navigate(to : ContactNavigationOptions, client: ChatClient, group: Group?, user: UserResponse?)
}

protocol ContactViewInterface: ViewInterface {
}

protocol ContactPresenterInterface: PresenterInterface {
    var output: ContactOutput? { get set}
    var contacts: [User] {get set}
    var searchContacts: [User] {get set}
    var isSearching: Bool {get set}
    var client: ChatClient? {get set}
    func viewModelDidLoad()
    func viewModelWillAppear()
    func rowsCount() -> Int
    func viewModelItem(row: Int) -> User
    func filterGroups(with text: String)
    func createGroup(with user: User)
    func navigate(to : ContactNavigationOptions, group: Group?)
}

protocol ContactInteractorInterface: InteractorInterface {
    func createGroup(with request: CreateGroupRequest, complition: @escaping ContactComplition)
    func fetchAllUser(complition: @escaping AllUserComplition)
}