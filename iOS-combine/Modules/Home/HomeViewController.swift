//  
//  HomeViewController.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 17/05/2021.
//

import UIKit

public class HomeViewController: UIViewController {

    var viewModel: HomeViewModel!
    @IBOutlet weak var containerView: UIView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
    }
    
    fileprivate func bindViewModel() {

        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            default:
                break
            }
        }
    }
}

extension HomeViewController {
    func configureAppearance() {
        containerView.layer.cornerRadius = 20
        self.navigationController?.navigationBar.isHidden = true
    }
}
