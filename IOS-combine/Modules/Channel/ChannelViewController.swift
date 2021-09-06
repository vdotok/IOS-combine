//
//  ChannelViewController.swift
//  IOS-combine
//
//  Created by usama farooq on 30/08/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class ChannelViewController: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emptyViewUserName: UILabel!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var emptyViewStatus: UIView! {
        didSet {
            emptyViewStatus.layer.cornerRadius = emptyViewStatus.frame.height/2
        }
    }
    @IBOutlet weak var emptyViewStatusVideoStream: UIView! {
        didSet {
            emptyViewStatusVideoStream.layer.cornerRadius = emptyViewStatusVideoStream.frame.height/2
        }
    }
    @IBOutlet weak var viewStatusVideoStream: UIView! {
        didSet {
            viewStatusVideoStream.layer.cornerRadius = viewStatusVideoStream.frame.height/2
        }
    }
    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.layer.cornerRadius = viewStatus.frame.height/2
        }
    }
    lazy var refreshControl = UIRefreshControl()
    
    private var selectedGroupId: Int? = nil
    let navigationTitle = UILabel()

    // MARK: - Public properties -

    var presenter: ChannelPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindPresenter()
        presenter.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(removeCount(notification:)), name: .removeCount, object: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    @IBAction func didTapReferesh(_ sender: UIButton) {
        presenter.fetchGroups()
    }
    
    @IBAction func didTapNewChat(_ sender: UIButton) {
//        didTappedAdd()
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "UserResponse")
        navigationController?.presentWireframe(LoginWireframe())
        presenter.logout()
    }
    
    private func bindPresenter() {
        presenter.channelOutput = { [unowned self]  output in
            switch output {
            case .reload:
                refreshControl.endRefreshing()
                tableView(isHidden: presenter.channelsCount() > 0 ? false : true)
                tableView.reloadData()
                
            case .showProgress:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    ProgressHud.show(viewController: self)
                }
            case .hideProgress:
                ProgressHud.hide()
            case .failure(message: let message):
                ProgressHud.showError(message: message, viewController: self)
            case .connected(let sdkType):
                if sdkType == SDKType.chat {
                    emptyViewStatus.backgroundColor = .green
                    viewStatus.backgroundColor = .green
                } else if sdkType == .stream {
                    emptyViewStatusVideoStream.backgroundColor = .green
                    viewStatusVideoStream.backgroundColor = .green
                }
            case .disconnected(let sdkType):
                if sdkType == SDKType.chat {
                    emptyViewStatus.backgroundColor = .red
                    viewStatus.backgroundColor = .red
                } else if sdkType == .stream {
                    emptyViewStatusVideoStream.backgroundColor = .red
                    viewStatusVideoStream.backgroundColor = .red
                }
            }
        }
    }
    
    @objc private func removeCount(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let channelName = userInfo["channelName"] as? String else { return }
        guard let chats = userInfo["chatMessages"] as? [ChatMessage] else {return}
        presenter.messages[channelName] = chats
        presenter.unreadMessages[channelName]?.removeAll()
    }

}

// MARK: - Extensions -

extension ChannelViewController {
    func configureAppearance() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        userName.text = user.fullName
        emptyViewUserName.text = user.fullName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
    //    tableView(isHidden: viewModel.groups.count > 0 ? false : true)
        configureEmptyView()
        navigationTitle.text = "Chat Rooms"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        self.navigationItem.leftBarButtonItem = leftItem
        let image = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(didTappedAdd)
        )
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        presenter.fetchGroups()
    }
    
    @objc func didTappedAdd() {
        presenter.moveToCreateGroup()
    }
    
    private func configureEmptyView() {
        titleLabel.textColor = .appDarkGreenColor
        titleLabel.font = UIFont(name: "Inter-Regular", size: 21)
        subTitle.textColor = .appLightIndigoColor
        subTitle.font = UIFont(name: "Poppins-Regular", size: 14)
        logoutButton.tintColor = .appIndigoColor
        logoutButton.titleLabel?.font = UIFont.init(name: "Manrope-Bold", size: 14)
    }
    private func tableView(isHidden: Bool) {
        if isHidden {
            tableView.isHidden = isHidden
            emptyView.isHidden = !isHidden
        } else {
            tableView.isHidden = isHidden
            emptyView.isHidden = !isHidden
        }
        
    }
}

extension ChannelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter.isSearching {
            // return pre.searchGroup.count
            return 0
        }
        return presenter.channelsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        cell.selectionStyle = .none
        guard let item = presenter.itemAt(row: indexPath.row) else {return UITableViewCell()}
        cell.configure(with: item.group,
                       online: item.presentParticipant + 1,
                       lastMessage: item.lastMessage,
                       unreadCount: item.unReadMessageCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let channel = presenter.groups[indexPath.row].channelName
        let topic =  presenter.messages[channel]
        presenter.navigation(to: .chat, messages: topic ?? [], group: presenter.groups[indexPath.row])
    }
    
    
}



extension ChannelViewController: ChannelViewInterface {
}
