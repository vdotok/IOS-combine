//
//  CreateGroupViewController.swift
//  IOS-combine
//
//  Created by usama farooq on 02/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class CreateGroupViewController: UIViewController {
    
    // MARK: - Public properties -
    
    var presenter: CreateGroupPresenterInterface!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    let navigationTitle = UILabel()
    
    // MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        presenter.viewModelDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewModelWillAppear()
    }
    
    func bindViewModel() {
        presenter.output = { [unowned self] output in
            switch output {
            case .showProgress:
                ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .failure(message: let message):
                ProgressHud.showError(message: message, viewController: self)
            case .updateRow(index: let index):
                let selectedIndexPath = IndexPath(item:index , section: 0)
                self.tableView.reloadRows(at: [selectedIndexPath], with: .none)
            case .reload:
                tableView.reloadData()
            case .groupCreated(group: let group):
                break
            //       moveToChat(group: group, isExist: false)
            //                self.navigationController?.popToRootViewController(animated: true)
            default:
                break
            }
        }
        
    }
    
    func moveToChat(group: Group, isExist: Bool) {
        
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        if !isExist {
            NotificationCenter.default.post(name: .didGroupCreated,
                                            object: self,
                                            userInfo: ["model" : group])
        }
     
//        let builder = ChatScreenBuilder()
//            .build(with: self.navigationController, client: viewModel.client, group: group, user: user, messages: [])
//        self.navigationController?.pushViewController(builder, animated: true)

    }
}
// MARK: - Extensions -

extension CreateGroupViewController {
    func configureAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.register(UINib(nibName: "CreateGroupCell", bundle: nil), forCellReuseIdentifier: "CreateGroupCell")
        configureNavigation()

    }
    
    private func configureNavigation() {
        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysOriginal)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(didTappedAdd)
        )
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        navigationTitle.text = "Create Group Chat"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
    }
    
    @objc func didTappedAdd() {
        if presenter.selectedItems.count >= 1 {
            if presenter.selectedItems.count < 2 {
                guard let user = presenter.contacts.first else { return }
                presenter.createGroup(with: user)
                return
            }
            let vc = CreateGroupPopUp()
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
            vc.delegate = self
            blurView.isHidden = false

        }
        
       
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.rowsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateGroupCell", for: indexPath) as! CreateGroupCell
        let item = presenter.viewModelItem(row: indexPath.row)
        cell.configure(with: item, selected: presenter.check(id: item.userID))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = presenter.viewModelItem(row: indexPath.row)
        presenter.addUser(userId: user.userID, row: indexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: Int = 0
        if presenter.searchContacts.count > 0
        {
            self.tableView.backgroundView = nil
            numOfSection = 1
        }
        else
        {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noDataLabel.text = "No User Found"
            noDataLabel.textColor = .appDarkColor
            noDataLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = noDataLabel
            
        }
        
        return numOfSection
    }
    
}

extension CreateGroupViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else {return}
        presenter.isSearching = true
        presenter.filterGroups(with: text)
        print(text)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension CreateGroupViewController: PopupDelegate {
    func didTapDismiss(groupName: String?) {
        
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
        guard let title = groupName else {return }
        presenter.createGroup(with: title)
    }
    
    func didTapDismiss() {
       
    }
}

extension CreateGroupViewController: CreateGroupViewInterface {
    
    
}
