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
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
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
    var incomingCallingView: GroupCallingUpdatedView?
    var smallCallingView: SmallCallingView?

    // MARK: - Public properties -

    var presenter: ChannelPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindPresenter()
        presenter.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(removeCount(notification:)), name: .removeCount, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didSubscribe(notification:)), name: .didGroupCreated, object: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        presenter.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(didDismiss), name: Notification.Name("didDismiss"), object: nil)
        
        if presenter.streamingManager.activeSession() != 0 {
            showSmallView()
        } else {
            self.tableViewTopConstraint.constant = 0
        }
        if presenter.streamingManager.activeSession() == 0 && smallCallingView != nil {
            UIApplication.shared.windows.first?.subviews[1].removeFromSuperview()
            smallCallingView = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didTapHangup), name: Notification.Name.hangup, object: nil)
    }
    
    @objc func showSmallView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableViewTopConstraint.constant = 140
        }
        
        UIApplication.shared.windows.first?.subviews[1].removeFromSuperview()
        let manager = presenter.streamingManager
        manager.vtokSDK = presenter.vtokSDK
        smallCallingView = SmallCallingView.getView(streamingManager: manager)
        smallCallingView?.getUserStream()
        UIApplication.shared.windows.first!.addSubview(smallCallingView!)
        smallCallingView?.addConstraintsFor(width: self.view.frame.width, and: 140)
        smallCallingView?.addTopConstraint(size: self.topbarHeight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.hangup, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didSubscribe(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let model = userInfo["model"] as? Group else {
            return
        }
        presenter.groups.insert(model, at: 0)
        presenter.subscribe(group: model)
        
    }
    
    @IBAction func didTapReferesh(_ sender: UIButton) {
        presenter.fetchGroups()
    }
    
    @IBAction func didTapNewChat(_ sender: UIButton) {
//        didTappedAdd()
        didTappedAdd()
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "UserResponse")
        defaults.synchronize()
        
//        UserDefaults.standard.removeObject(forKey: "UserResponse")
        presenter.logout()
        navigationController?.presentWireframe(LoginWireframe(streamingManager: self.presenter.streamingManager))
     //   navigationController?.presentWireframe(LoginWireframe(streamingManager: <#StreamingMananger#>))
        
    }
    
    @objc func didDismiss() {
        
    }
    
    @objc func didTapHangup() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            guard let view = UIApplication.shared.windows.first?.subviews[1] else {return}
            view.removeFromSuperview()
            self.tableViewTopConstraint.constant = 0
            self.smallCallingView = nil
        }
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
                 //   emptyViewStatus.backgroundColor = .green
                    viewStatus.backgroundColor = .green
                } else if sdkType == .stream {
                  //  emptyViewStatusVideoStream.backgroundColor = .green
                    viewStatusVideoStream.backgroundColor = .green
                }
            case .disconnected(let sdkType):
                if sdkType == SDKType.chat {
                //    emptyViewStatus.backgroundColor = .red
                    viewStatus.backgroundColor = .red
                } else if sdkType == .stream {
                //    emptyViewStatusVideoStream.backgroundColor = .red
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

    func configureNavigationBar() {
        let broadCast = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        broadCast.setImage(UIImage(named: "public-broadcast"), for: .normal)
        broadCast.addTarget(self, action: #selector(didTapBroadCast), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: navigationTitle)
        let broadCastBarButton =  UIBarButtonItem(customView: broadCast)
        self.navigationItem.leftBarButtonItem = leftItem
        let image = UIImage(named: "plus")?.withRenderingMode(.alwaysOriginal)
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(didTappedAdd))
        
        navigationItem.rightBarButtonItems = [addButton,broadCastBarButton ]
        
        if presenter.streamingManager.activeSession() != 0 {
            broadCast.tintColor = .appGreyColor
            broadCast.isEnabled = false
        } else {
            broadCast.tintColor = .appDarkGreenColor
            broadCast.isEnabled = true
        }
        
    }
}

// MARK: - Extensions -

extension ChannelViewController {
    func configureAppearance() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        userName.text = user.fullName
      // emptyViewUserName.text = user.fullName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChannelCell", bundle: nil), forCellReuseIdentifier: "ChannelCell")
        //    tableView(isHidden: viewModel.groups.count > 0 ? false : true)
        configureEmptyView()
        navigationTitle.text = "Chat Rooms"
        navigationTitle.font = UIFont(name: "Manrope-Medium", size: 20)
        navigationTitle.textColor = .appDarkGreenColor
        navigationTitle.sizeToFit()
       
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        presenter.fetchGroups()
    }
    
    @objc func didTapBroadCast() {
        presenter.navigation(to: .broadcastOverlay, messages: [], group: nil)
    }
    
    @objc func didTappedAdd() {
        
//        let view = GroupCallingUpdatedView.getView()
//        self.incomingCallingView = view
//
//        guard let incomingCallingView = self.incomingCallingView else {return}
////        view.configureView(baseSession: session, user: contact)
////        view.session = session
////        incomingCallingView.delegate = self
//        incomingCallingView.translatesAutoresizingMaskIntoConstraints = false
//        self.view.addSubview(incomingCallingView)
//
//        NSLayoutConstraint.activate([
//            incomingCallingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
//            incomingCallingView.trailingAnchor.constraint(equalTo:self.view.trailingAnchor),
//            incomingCallingView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            incomingCallingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
//        ])
        
        
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
        let channel = presenter.groups[indexPath.row].channelName
        let topic =  presenter.messages[channel]
        presenter.navigation(to: .chat, messages: topic ?? [], group: presenter.groups[indexPath.row])
    }
    
    
}



extension ChannelViewController: ChannelViewInterface {
}
