//  
//  ContactViewController.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 20/05/2021.
//

import UIKit

public class ContactViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var addGroup: UIButton!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    let navigationTitle = UILabel()
    
    
    var viewModel: ContactViewModel!
    
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
    
    
    @IBAction func didTapAddContact(_ sender: UIButton) {
        let vc = CreateGroupBuilder()
            .build(with: self.navigationController, client: viewModel.client!)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func bindViewModel() {
        
        viewModel.output = { [unowned self] output in
            //handle all your bindings here
            switch output {
            case .showProgress:
                ProgressHud.show(viewController: self)
            case .hideProgress:
                ProgressHud.hide()
            case .failure(message: let message):
                DispatchQueue.main.async {
                    ProgressHud.showError(message: message, viewController: self)
                }
            case .reload:
                tableView.reloadData()
            case .groupCreated(group: let group, isExit: let isExist):
                moveToChat(group: group, isExist: isExist)
                
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
        
        let builder = ChatScreenBuilder()
            .build(with: self.navigationController, client: viewModel.client!, group: group, user: user, messages: [])
        self.navigationController?.pushViewController(builder, animated: true)

    }
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
//        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysOriginal)
//
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            image: image,
//            style: .plain,
//            target: self,
//            action: #selector(didTappedAdd)
//        )
    }
    
    @objc func didTappedAdd() {
        navigationController?.popViewController(animated: true)
    }
}

extension ContactViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        cell.selectionStyle = .none
        cell.configure(with: viewModel.viewModelItem(row: indexPath.row))
        cell.delegate = self
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let user = viewModel.viewModelItem(row: indexPath.row)
//        viewModel.createGroup(with: user)
        
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSection: Int = 0
        if viewModel.searchContacts.count > 0
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
        viewModel.isSearching = true
        viewModel.filterGroups(with: text)
        print(text)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension ContactViewController: ContactCellProtocol {
    func didTapVideo(user: User) {
        self.viewModel.callingDelegate?.initiatedCall(users: [user], callType: .video)
    }
    
    func didTapAudio(user: User) {
        self.viewModel.callingDelegate?.initiatedCall(users: [user], callType: .audio)
    }
    
    func didTapChat(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        let user = viewModel.viewModelItem(row: indexPath.row)
        viewModel.createGroup(with: user)
    }
    
    
}
