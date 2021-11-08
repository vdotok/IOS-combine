//
//  ChatViewController.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import IQKeyboardManagerSwift
import MMWormhole

final class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var messageInputHieght: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var callingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    var isCallingView: Bool = false
    var users: [String] = []
    var timer: Timer? = nil
    let wormhole = MMWormhole(applicationGroupIdentifier: AppsGroup.APP_GROUP,
                              optionalDirectory: "wormhole")
    
    
    lazy var titleLabel: UILabel = {
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Inter-Regular", size: 14)
        titleLabel.textColor = .appTileGreen
        return titleLabel
    }()
    
    lazy var subTitle: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.textAlignment = .left
        subtitleLabel.font = UIFont(name: "Inter-Regular", size: 14)
        subtitleLabel.textColor = .appLightGreen
        return subtitleLabel
    }()
    
    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitle])
        stackView.axis = .vertical
        return stackView
    }()
    
    lazy var documentPicker = DocumentPicker(viewController: self, delegate: self)
    lazy var imagePicker: ImagePicker = ImagePicker(presentationController: self, delegate: self)

    lazy var audioBarButton = UIBarButtonItem(image: UIImage(named: "call"), style: .plain, target: self, action: #selector(audioCallAction(_:)))
    lazy var videoBarButton = UIBarButtonItem(image: UIImage(named: "Icon ionic-ios-videocam"), style: .plain, target: self, action: #selector(videoCallAction(_:)))
    lazy var broadcastButton = UIBarButtonItem(image: UIImage(named: "broadcast-icon"), style: .plain, target: self, action: #selector(broadcastAction))
    // MARK: - Public properties -

    var presenter: ChatPresenterInterface!

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindPresenter()
        notificationsListners()
        titleLabel.text = presenter.group?.groupTitle
       
        listenForHangup()
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        iqKeyBoard(isEnable: false)
        if presenter.streamingManager?.activeSession() != 0 {
            showSmallView()
        } else {
          
            tableViewTopConstraint.constant = 0
        }
        
      addNotificationObserver()
        showBroadcastBanner()
        if presenter.streamingManager?.activeSession() == 0 && AppDelegate.appDelegate.smallCallingView != nil {
            AppDelegate.appDelegate.smallCallingView.removeFromSuperview()
            AppDelegate.appDelegate.smallCallingView = nil
        }
        
//        NotificationCenter.default.post(name: Notification.Name.hangup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didTapHangup), name: Notification.Name.hangup, object: nil)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
        NotificationCenter.default.removeObserver(self, name: Notification.Name.hangup, object: nil)
        
    }
    
    func listenForHangup() {
        wormhole.listenForMessage(withIdentifier: "sessionHangup", listener: { [weak self] (messageObject) -> Void in
            guard let self = self else {return}
            AppDelegate.appDelegate.smallCallingView?.removeFromSuperview()
            self.tableViewTopConstraint.constant = 0
            AppDelegate.appDelegate.smallCallingView = nil
            self.audioBarButton.tintColor = .appDarkGreenColor
            self.videoBarButton.tintColor = .appDarkGreenColor
            self.broadcastButton.tintColor = .appDarkGreenColor
            self.audioBarButton.isEnabled = true
            self.videoBarButton.isEnabled = true
            self.broadcastButton.isEnabled = true
        })
    }
    
    @objc func didTapHangup() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            AppDelegate.appDelegate.smallCallingView?.removeFromSuperview()
            self.tableViewTopConstraint.constant = 0
            AppDelegate.appDelegate.smallCallingView = nil
            
        }
    
    }
    
    @objc func showSmallView() {
        tableViewTopConstraint.constant = 140 + topbarHeight
        if let smallCallingView = AppDelegate.appDelegate.smallCallingView {
            smallCallingView.removeFromSuperview()
        }
       
        let manager = presenter.streamingManager
        manager?.groupID = presenter.group?.id
        manager?.vtokSDK = presenter.sdk
        AppDelegate.appDelegate.smallCallingView = SmallCallingView.getView(streamingManager: manager!)
        AppDelegate.appDelegate.smallCallingView?.getUserStream()
        AppDelegate.appDelegate.smallCallingView?.groupID = presenter.group?.id
        AppDelegate.appDelegate.smallCallingView?.delegate = self
       UIApplication.shared.windows.first!.addSubview(AppDelegate.appDelegate.smallCallingView)
        AppDelegate.appDelegate.smallCallingView?.addConstraintsFor(width: self.view.frame.width, and: 140)
        AppDelegate.appDelegate.smallCallingView?.addTopConstraint(size: self.topbarHeight)
    
    }
    
    func showBroadcastBanner() {
        
        guard let manager = presenter.streamingManager else {return}
        if UIScreen.main.isCaptured && presenter.streamingManager?.activeSession() == 0 {
            DispatchQueue.main.async { [weak self] in
                self?.tableViewTopConstraint.constant = 20
            }
            AppDelegate.appDelegate.screenShareBannerView = ScreenShareBannerView.getView(streamingManager: manager)
            UIApplication.shared.windows.first!.addSubview(AppDelegate.appDelegate.screenShareBannerView)
            AppDelegate.appDelegate.screenShareBannerView?.addConstraintsFor(width: self.view.frame.width, and: 20)
            AppDelegate.appDelegate.screenShareBannerView.addTopConstraint(size: self.topbarHeight)
        }
        if !UIScreen.main.isCaptured && AppDelegate.appDelegate.screenShareBannerView != nil {
            AppDelegate.appDelegate.screenShareBannerView.removeFromSuperview()
        }
    }
    
    deinit {
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.traitCollection.horizontalSizeClass == .compact {
            titleStackView.axis = .vertical
            titleStackView.spacing = UIStackView.spacingUseDefault
        } else {
            titleStackView.axis = .horizontal
            titleStackView.spacing = 20.0
        }
    }
    
    @IBAction func didTapSend(_ sender: UIButton) {
        
        let messageText = messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if messageText.count != 0 {
            presenter.sendMessage(text: messageTextField.text!)
            self.messageTextField.text = ""
            self.messageTextField.checkPlaceholder()
            sendMessageButton.tintColor = .appDarkGray
            let height = messageTextField.contentSize.height
            DispatchQueue.main.async {
                self.messageInputHieght.constant = height
            }
        }
       
    }
    
    @IBAction func didTapAttachment(_ sender: UIButton) {
//                documentPicker.displayPicker()
        let vc = AttachmentViewController()
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        present(vc, animated: true, completion: nil)
        blurView.isHidden = false
    }
    
    @IBAction func didTapImage(_ sender: UIButton) {
        imagePicker.action(for: .savedPhotosAlbum)
        
    }
    
    func bindPresenter() {
        presenter.chatOutput = { [unowned self] output in
            switch output {
            case .reload:
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    let reloadIndexPath = IndexPath(item: (self.presenter.messages?.count ?? 0) - 1, section: 0)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at:[reloadIndexPath], with: .fade)
                        self.tableView.endUpdates()
                        self.tableView.scrollToRow(at: reloadIndexPath, at: .bottom, animated: false)

                    }, completion: nil)
            
            case .reloadCell(let indexPath):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            
            }
        }
    }

}


// MARK: - Extensions -

extension ChatViewController: ChatViewInterface {
}


// MARK: - Document picker
extension ChatViewController: DocumentPickerProtocol {
    func didPickDocument(document: Document?) {
        
    }
    
    func didTapdismiss() {
        
    }
    
    
    
    
}

// MARK: - Image picker
extension ChatViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        
    }
    
    
}

// MARK: - TableView

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.messageCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = presenter.itemAt(row: indexPath.row)
       
        switch item.1 {
        case .outGoingText:
          
            return inComingCell(indexPath: indexPath, item: item.0)
        case .incomingText:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingTextCell", for: indexPath) as! OutgoingTextCell
            presenter.sendSeenMessage(message: item.0, row: indexPath.row)
            guard let userName = presenter.group?.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
            cell.backgroundColor = .appLightGrey
            cell.userName.text = userName.fullName
            cell.messageLabel.text = item.0.content
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            return cell
        case .incomingAttachment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingAttachmentCell", for: indexPath) as! IncomingAttachmentCell
            cell.url = item.0.fileType!
            presenter.sendSeenMessage(message: item.0, row: indexPath.row)
            cell.delegate = self
            guard let user = presenter.group?.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
            cell.userName.text = user.fullName
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            cell.backgroundColor = .appLightGrey
        
            return cell
        case .outgoingAttachment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingAttachementCell", for: indexPath) as! OutgoingAttachementCell
            cell.url = item.0.fileType!
            cell.delegate = self
            cell.configure(seen: item.0.status.toImage() ?? "")
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            cell.backgroundColor = .appLightGrey
            return cell
            
        case .incomingImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingImageCell", for: indexPath) as! IncomingImageCell
            cell.backgroundColor = .appLightGrey
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            presenter.sendSeenMessage(message: item.0, row: indexPath.row)
            cell.configure(with: item.0.fileType)
            guard let user = presenter.group?.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
            cell.userName.text = user.fullName
            return cell
        case .outGoingImage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingImageCell", for: indexPath) as! outgoingImageCell
            cell.backgroundColor = .appLightGrey
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            cell.configure(with: item.0.fileType)
            cell.configure(seen: item.0.status.toImage() ?? "")
            return cell
        default:
            break
        }
      return UITableViewCell()
        
    }
    
    private func inComingCell( indexPath: IndexPath, item: ChatMessage) -> IncomingTextCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingTextCell", for: indexPath) as! IncomingTextCell
        cell.messageLabel.text = item.content
        cell.timeLabel.text = item.date.toDateTime.toTimeString
        cell.bubbleView.backgroundColor = .white
        cell.backgroundColor = .appLightGrey
        cell.messageLabel.textColor = .appDarkerGray
        cell.timeLabel.font = UIFont(name: "Inter-Regular", size: 14)
        cell.messageStatus.font = UIFont(name: "Inter-Regular", size: 14)
        cell.bubbleView.layer.cornerRadius = 8
        cell.configure(seen: item.status.toImage() ?? "chupaaang")
        return cell
    }
    
    
}

// MARK: - UITextViewDelegate
 
extension ChatViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        
        guard textView.text.count <= 400 else {
            self.messageTextField.text = textView.text.prefix(400).description
            sendMessageButton.isEnabled = false
            ProgressHud.showError(message: "Text should be 400 character", viewController: self)
            return
        }
        let height = textView.contentSize.height
        DispatchQueue.main.async {
            if height < 100 {
                self.messageInputHieght.constant = height
            }
            textView.checkPlaceholder()
        }
        if textView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            
            sendMessageButton.tintColor = .appDarkGray
        } else {
            sendMessageButton.isEnabled = true
            sendMessageButton.tintColor = .appGreenColor
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(sendStopTyping), userInfo: nil, repeats: false)
        presenter.dispatchPackage(start: true)
        
    }
    
    @objc func sendStopTyping() {
        timer?.invalidate()
        timer = nil
        presenter.dispatchPackage(start: false)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        presenter.dispatchPackage(start: false)
        return true
    }
    
    func sendEndTyping(count: Int) {
            
        
        }
}
 
// MARK: AttachmentPickerDelegate

extension ChatViewController: AttachmentPickerDelegate {
    func didSelectImage(data: Data) {
        
    }
    
    func didSelectDocument(data: Data, fileExtension: String) {
        
    }
    
    func didCancel() {
        
    }
    
    
}


// MARK: -

extension ChatViewController {
    func configureAppearance() {
        registerCells()
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .appLightGrey
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        configureNavigationView()
        //        messageTextField.text = "Type your message"
        let image = UIImage(named: "Icon-send")!.withRenderingMode(.alwaysTemplate)
        sendMessageButton.setImage(image, for: .normal)
        sendMessageButton.tintColor = .appDarkGray
        messageTextField.setPlaceholder()

    }
    
    func configureNavigationBar() {
       
        
        self.navigationItem.setRightBarButtonItems([ videoBarButton,audioBarButton, broadcastButton], animated: true)
        if presenter.streamingManager?.activeSession() != 0 {
            audioBarButton.tintColor = .appGreyColor
            videoBarButton.tintColor = .appGreyColor
            broadcastButton.tintColor = .appDarkGray
            audioBarButton.isEnabled = false
            videoBarButton.isEnabled = false
            broadcastButton.isEnabled = false
        } else {
            audioBarButton.tintColor = .appDarkGreenColor
            videoBarButton.tintColor = .appDarkGreenColor
            broadcastButton.tintColor = .appDarkGreenColor
            audioBarButton.isEnabled = true
            videoBarButton.isEnabled = true
            broadcastButton.isEnabled = true
        }
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: "OutgoingTextCell", bundle: nil), forCellReuseIdentifier: "OutgoingTextCell")
        tableView.register(UINib(nibName: "IncomingTextCell", bundle: nil), forCellReuseIdentifier: "IncomingTextCell")
        tableView.register(UINib(nibName: "OutgoingAudioCell", bundle: nil), forCellReuseIdentifier: "OutgoingAudioCell")
        tableView.register(UINib(nibName: "IncomingAudioCell", bundle: nil), forCellReuseIdentifier: "IncomingAudioCell")
        tableView.register(UINib(nibName: "IncomingAttachmentCell", bundle: nil), forCellReuseIdentifier: "IncomingAttachmentCell")
        tableView.register(UINib(nibName: "OutgoingAttachementCell", bundle: nil), forCellReuseIdentifier: "OutgoingAttachementCell")
        tableView.register(UINib(nibName: "IncomingImageCell", bundle: nil), forCellReuseIdentifier: "IncomingImageCell")
        tableView.register(UINib(nibName: "outgoingImageCell", bundle: nil), forCellReuseIdentifier: "outgoingImageCell")
       
    }
    private func configureNavigationView() {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: titleStackView)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
    }
    
    @objc func audioCallAction(_ sender: UIView) {
        let groupId = presenter.group?.id
        let userInfo: [String: Any] = ["callType": NotifyCallType.audio.callType,
                                       "groupId": groupId ?? 0]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
    }
    
    @objc func videoCallAction(_ sender: UIView) {
        let groupId = presenter.group?.id
        let userInfo: [AnyHashable: Any]? = ["callType": NotifyCallType.video.callType,
                                       "groupId": groupId ?? 0]
        NotificationCenter.default.post(name: NotifyCallType.notificationName, object: userInfo)
    }
    
    @objc func broadcastAction() {
        
        presenter.moveToBroadcast()
    }
    
    
    @objc func didTapBackButton() {
        NotificationCenter.default.post(name: .removeCount,
                                        object: self,
                                        userInfo: ["channelName" : presenter.group?.channelName ?? "",
                                                   "chatMessages": presenter.messages ?? ""]
                                            )
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func notificationsListners() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + user.fullName!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedMessage(notification:)), name: name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartTyping(notification:)), name: NSNotification.Name("didStartTyping" + user.fullName!), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndTyping(notification:)), name: NSNotification.Name("didEndTyping" + user.fullName!), object: nil)
    }
    
    @objc func receivedMessage(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        presenter.receivedMessage(userInfo: userInfo)
    }
    
    @objc func didStartTyping(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let name = userInfo["message"] as? String,let topic = userInfo["topic"] as? String, name != presenter.user?.refID  else { return }
        guard topic == presenter.group?.channelName else {return}
        guard let userName = presenter.group?.participants.filter({$0.refID == name}).first else {return}
        
        if !users.contains(userName.fullName) {
            users.append(userName.fullName)
        }
        let names = users.map({$0}).joined(separator: ",")
        subTitle.text = "\(names)" + " \(users.count == 1 ? "is" : "are") typing..."
        
        
    }
    
    @objc func didEndTyping(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let name = userInfo["message"] as? String, let topic = userInfo["topic"] as? String, name != self.presenter.user?.fullName else { return }
        guard topic == presenter.group?.channelName else {return}
        guard let userName = presenter.group?.participants.filter({$0.refID == name}).first else {return}
        users.removeAll(where: {$0 == userName.fullName})
        if users.count == 0 {
            subTitle.text = ""
        } else {
            let names = users.map({$0}).joined(separator: ",")
            subTitle.text = "\(names)" + " \(users.count == 1 ? "is" : "are") typing..."
        }
    }
}

extension ChatViewController {
    private func iqKeyBoard(isEnable: Bool) {
        IQKeyboardManager.shared.enable = isEnable
        IQKeyboardManager.shared.enableAutoToolbar = isEnable
    }
    
    @objc func keyboardNotification(notification: NSNotification) {

        let isShowing = notification.name == UIResponder.keyboardWillShowNotification

            if let userInfo = notification.userInfo {
                let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let endFrameHeight = endFrame?.size.height ?? 0.0
                let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                
                let animationCurveRaw =  UIView.AnimationOptions.curveEaseInOut.rawValue
                let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                self.bottomConstraint.constant = isShowing ? endFrameHeight : 38
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.scrollToBottom()
                }
                UIView.animate(withDuration: duration,
                                           delay: TimeInterval(0),
                    options: animationCurve,
                    animations: {
                        self.view.layoutIfNeeded() },
                    completion: nil)
            }
        }
    
    private func scrollToBottom() {
        let index = IndexPath(row: (presenter.messages?.count ?? 0) - 1, section: 0)
        if presenter.messages?.count ?? 0 > 4 {
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
        
    }
}

extension ChatViewController: DidTapAttachmentDelagate {
    func didTapAttachment(url: URL) {
        
    }
    
    
}

extension ChatViewController: SmallCallingViewDelegate {
    func didTapView() {
       // UIApplication.shared.windows.first!.subviews.last?.removeFromSuperview()
        isCallingView = true
    }
    
    
}



extension ChatViewController {
    func addNotificationObserver(){
          // Add Key-Value observer on isCaptured property of uiscreen.main
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)

      }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "captured" {

          if !UIScreen.main.isCaptured {
       
              AppDelegate.appDelegate.screenShareBannerView?.removeFromSuperview()
              
          } else {
              print("capture start")
          }
            
        }

    }
}
