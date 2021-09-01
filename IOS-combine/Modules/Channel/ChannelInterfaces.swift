//
//  ChannelInterfaces.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import iOSSDKConnect

enum ChannelNavigationOptions {
    case chat
}



typealias ChannelOutput = (ChannelPresenter.Output) -> Void

typealias ChannelComplition = ((Result<GroupResponse, Error>) -> Void)

protocol ChannelWireframeInterface: WireframeInterface {
    func move(to: ChannelNavigationOptions,client: ChatClient, group: Group, user: UserResponse, messages: [ChatMessage])
}

protocol ChannelViewInterface: ViewInterface {
}

protocol ChannelPresenterInterface: PresenterInterface {
    var channelOutput: ChannelOutput? {get set}
    var isSearching: Bool {get set }
    var messages: [String: [ChatMessage]] {get set}
    var groups: [Group]  {get set}
    func fetchGroups()
    func viewDidLoad()
    func viewWillAppear()
    func itemAt(row: Int) -> TempGroup?
    func channelsCount() -> Int
    func logout()
    func navigation(to: ChannelNavigationOptions, messages: [ChatMessage], group: Group)
   

    
}

protocol ChannelInteractorInterface: InteractorInterface {
    
    func fetchGroups(complition: @escaping ChannelComplition)
}
