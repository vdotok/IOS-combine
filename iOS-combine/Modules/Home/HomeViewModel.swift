//  
//  HomeViewModel.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 17/05/2021.
//

import Foundation

typealias HomeViewModelOutput = (HomeViewModelImpl.Output) -> Void

protocol HomeViewModelInput {
    
}

protocol HomeViewModel: HomeViewModelInput {
    var output: HomeViewModelOutput? { get set}
    
    func viewModelDidLoad()
    func viewModelWillAppear()
}

class HomeViewModelImpl: HomeViewModel, HomeViewModelInput {

    private let router: HomeRouter
    var output: HomeViewModelOutput?
    
    init(router: HomeRouter) {
        self.router = router
    }
    
    func viewModelDidLoad() {
        
    }
    
    func viewModelWillAppear() {
        
    }
    
    //For all of your viewBindings
    enum Output {
        
    }
}

extension HomeViewModelImpl {

}
