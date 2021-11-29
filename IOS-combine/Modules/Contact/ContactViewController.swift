//
//  ContactViewController.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ContactViewController: UIViewController {

    // MARK: - Public properties -
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addGroup: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    let navigationTitle = UILabel()
    

    var presenter: ContactPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        presenter.viewModelDidLoad()
    }
    
    @IBAction func didTapAddContact(_ sender: UIButton) {
        presenter.navigate(to: .createGroup, group: nil)
    }
    
    func bindViewModel() {
        presenter.output = { [unowned self] output in
            switch output {
            case .reload:
                tableView.reloadData()
            case .showProgress:
                ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .failure(message: let message):
                DispatchQueue.main.async {
                    ProgressHud.showError(message: message, viewController: self)
                }
            case .groupCreated(group: let group, isExit: let isExit):
                moveToChat(group: group, isExist: isExit)
            case .alreadyCreated(_):
                break
            }
        }
    }

}

// MARK: - Extensions -

extension ContactViewController: ContactViewInterface {
}

extension ContactViewController {
    func configureAppearance() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        separatorView.backgroundColor = .appTileGreenColor
        addGroup.titleLabel?.font = UIFont(name: "Manrope-Medium", size: 16)
        addGroup.setTitleColor(.appDarkColor, for: .normal)
        contactLabel.font = UIFont(name: "Manrope-Medium", size: 16)
        contactLabel.textColor = .appDarkColor
        
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        navigationTitle.text = "New Chat"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
        registerCell()
        configureNavigation()
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
    }
    
    @objc func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    private func configureNavigation() {

    }
    
    @objc func didTappedAdd() {
        navigationController?.popViewController(animated: true)
    }
    
    func moveToChat(group: Group, isExist: Bool) {
        if !isExist {
            NotificationCenter.default.post(name: .didGroupCreated,
                                            object: self,
                                            userInfo: ["model" : group])
        }
        presenter.navigate(to: .chat, group: group)
    }

}


extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.rowsCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.selectionStyle = .none
        cell.configure(with: presenter.viewModelItem(row: indexPath.row))
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = presenter.viewModelItem(row: indexPath.row)
        presenter.createGroup(with: user)
        
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
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

extension ContactViewController: UISearchBarDelegate {
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

extension ContactViewController: ContactCellProtocol {
    func didTapChat() {

    }
}
