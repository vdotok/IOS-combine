//  
//  ChatScreenViewController.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 18/05/2021.
//

import UIKit
import IQKeyboardManagerSwift

public class ChatScreenViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var messageInputHieght: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    var users: [String] = []
    
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
    
    var viewModel: ChatScreenViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        bindViewModel()
        viewModel.viewModelDidLoad()
        notificationsListners()
        titleLabel.text = viewModel.group.groupTitle
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewModelWillAppear()
        
        iqKeyBoard(isEnable: false)
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom()
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        iqKeyBoard(isEnable: true)
    }

    fileprivate func bindViewModel() {

        viewModel.output = { [weak self] output in
            //handle all your bindings here
            guard let self = self else { return }
            switch output {
            case .reload:
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                    let reloadIndexPath = IndexPath(item: self.viewModel.messages.count - 1, section: 0)
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at:[reloadIndexPath], with: .fade)
                        self.tableView.endUpdates()
                        self.tableView.scrollToRow(at: reloadIndexPath, at: .bottom, animated: false)

                    }, completion: nil)
            case .reloadCell(indexPath: let indexPath):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                
            default:
                break
            }
        }
    }
    
    @objc func didTapBackButton() {
        NotificationCenter.default.post(name: .removeCount,
                                        object: self,
                                        userInfo: ["channelName" : self.viewModel.group.channelName,
                                                   "chatMessages": self.viewModel.messages]
                                            )
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func receivedMessage(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        viewModel.receivedMessage(userInfo: userInfo)
    }
    
    @IBAction func didTapSend(_ sender: UIButton) {
        
        let messageText = messageTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if messageText.count != 0 {
            viewModel.sendMessage(text: messageTextField.text!)
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
    
    private func scrollToBottom() {
        let index = IndexPath(row: viewModel.messages.count - 1, section: 0)
        if viewModel.messages.count > 4 {
            tableView.scrollToRow(at: index, at: .bottom, animated: true)
        }
        
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
    
    
}

extension ChatScreenViewController {
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
       
        let audioBarButton = UIBarButtonItem(image: UIImage(named: "phone-receiver"), style: .plain, target: self, action: #selector(audioCallAction(_:)))
        let videoBarButton = UIBarButtonItem(image: UIImage(named: "videoCall"), style: .plain, target: self, action: #selector(videoCallAction(_:)))
        self.navigationItem.setRightBarButtonItems([videoBarButton, audioBarButton], animated: true)
        
    }
    
    @objc func audioCallAction(_ sender: UIView) {
        let groupId = self.viewModel.group.id
        viewModel.callingDelegate?.initiatedCall(in: groupId, callType: .audio)
    }
    
    @objc func videoCallAction(_ sender: UIView) {
        let groupId = self.viewModel.group.id
        viewModel.callingDelegate?.initiatedCall(in: groupId, callType: .video)
    }
    
    private func configureNavigationView() {
        let button = UIButton()
        button.setImage(UIImage(named: "arrow-left"), for: .normal)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: titleStackView)
        let leftItem2 = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [leftItem2,leftItem]
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
    
    private func notificationsListners() {
        guard let user = VDOTOKObject<UserResponse>().getData() else {return}
        let name = NSNotification.Name(rawValue: "MQTTMessageNotification" + user.fullName!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.receivedMessage(notification:)), name: name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name:UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStartTyping(notification:)), name: NSNotification.Name("didStartTyping" + user.fullName!), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEndTyping(notification:)), name: NSNotification.Name("didEndTyping" + user.fullName!), object: nil)
    }
    
    @objc func start() {
//        micButton.setImage(UIImage(named: "MicFilled"), for: .normal)
        
    }
    @objc func end() {
//        micButton.setImage(UIImage(named: "Mic"), for: .normal)
        
    }
    
    func dispatchPackage(start: Bool = false) {
        let date = Date().millisecondsSince1970
        if start {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: viewModel.group.channelName,
                                            key: viewModel.group.channelKey,
                                            from: viewModel.user.refID!,
                                            type: "typing",
                                            content: "1",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            self.viewModel.mqtt.publish(message: messageModel)
        } else {
            let messageModel = MessageModel(id: UUID().uuidString,
                                            to: viewModel.group.channelName,
                                            key: viewModel.group.channelKey,
                                            from: viewModel.user.refID!,
                                            type: "typing",
                                            content: "0",
                                            size: 0,
                                            isGroupMessage: false,
                                            status: 0,
                                            date: 1622801248314)
            self.viewModel.mqtt.publish(message: messageModel)
        }
        
    }
    
    @objc func didStartTyping(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let name = userInfo["message"] as? String,let topic = userInfo["topic"] as? String, name != self.viewModel.user.refID  else { return }
        guard topic == viewModel.group.channelName else {return}
        guard let userName = viewModel.group.participants.filter({$0.refID == name}).first else {return}
        
        if !users.contains(userName.fullName) {
            users.append(userName.fullName)
        }
        let names = users.map({$0}).joined(separator: ",")
        subTitle.text = "\(names)" + " \(users.count == 1 ? "is" : "are") typing..."
        
        
    }
    
    @objc func didEndTyping(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        guard let name = userInfo["message"] as? String, let topic = userInfo["topic"] as? String, name != self.viewModel.user.fullName else { return }
        guard topic == viewModel.group.channelName else {return}
        guard let userName = viewModel.group.participants.filter({$0.refID == name}).first else {return}
        users.removeAll(where: {$0 == userName.fullName})
        if users.count == 0 {
            subTitle.text = ""
        } else {
            let names = users.map({$0}).joined(separator: ",")
            subTitle.text = "\(names)" + " \(users.count == 1 ? "is" : "are") typing..."
        }
    }
        
}


extension ChatScreenViewController: UITableViewDataSource, UITableViewDelegate{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messageCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.itemAt(row: indexPath.row)
       
        switch item.1 {
        case .outGoingText:
          
            return inComingCell(indexPath: indexPath, item: item.0)
        case .incomingText:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingTextCell", for: indexPath) as! OutgoingTextCell
            viewModel.sendSeenMessage(message: item.0, row: indexPath.row)
            guard let userName = viewModel.group.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
            cell.backgroundColor = .appLightGrey
            cell.userName.text = userName.fullName
            cell.messageLabel.text = item.0.content
            cell.timeLabel.text = item.0.date.toDateTime.toTimeString
            return cell
        case .incomingAttachment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingAttachmentCell", for: indexPath) as! IncomingAttachmentCell
            cell.url = item.0.fileType!
            viewModel.sendSeenMessage(message: item.0, row: indexPath.row)
            cell.delegate = self
            guard let user = viewModel.group.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
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
            viewModel.sendSeenMessage(message: item.0, row: indexPath.row)
            cell.configure(with: item.0.fileType)
            guard let user = viewModel.group.participants.filter({$0.refID == item.0.sender}).first else { return UITableViewCell() }
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
        if let seenCount = self.viewModel.messagesSeenCount[indexPath.row], let label = cell.messageStatus.text {
            cell.configure(seen: label + " " + "\(seenCount.count)")
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}

extension ChatScreenViewController: UITextViewDelegate {
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
       
        viewModel.dispatchPackage(start: true)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.checkPlaceholder()
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        viewModel.dispatchPackage(start: false)
        return true
    }
}

extension ChatScreenViewController {
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
}

extension ChatScreenViewController: PopupDelegate {
    func didTapDismiss(groupName: String?) {
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
    }
}


extension ChatScreenViewController: DocumentPickerProtocol {
    func didTapdismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            let fileURL = pickedDoc.fileURL
            let fileName = (fileURL.absoluteString as NSString).lastPathComponent
            let fileExtn = fileName.components(separatedBy: ".")[1]
            let documentData: Data = try! Data(contentsOf: fileURL)
            print(fileExtn)
            viewModel.publish(file: documentData, with: fileExtn, type: MediaType.file.rawValue)
        }
    }
    
}

extension ChatScreenViewController: DidTapAttachmentDelagate {
    func didTapAttachment(url: URL) {
        let dc = UIDocumentInteractionController(url: url)
        dc.delegate = self
        UINavigationBar.appearance().tintColor = .black
        dc.presentPreview(animated: true)
    }
    
}

extension ChatScreenViewController: UIDocumentInteractionControllerDelegate {
    public func documentInteractionControllerViewControllerForPreview
        (_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

extension ChatScreenViewController: ImagePickerDelegate {
    public func didSelect(image: UIImage?) {
        if let image = image {
            let jpegData = image.jpegData(compressionQuality: 0.2)
            let pngData = image.pngData()
            viewModel.publish(file: jpegData!, with: "PNG", type: MediaType.image.rawValue)
        }
    }
    
    
}

extension ChatScreenViewController: AttachmentPickerDelegate {
    func didSelectImage(data: Data) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
        viewModel.publish(file: data, with: "PNG", type: MediaType.image.rawValue)
    }
    
    func didSelectDocument(data: Data, fileExtension: String) {
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
        presentedViewController?.dismiss(animated: true, completion: nil)

        var mediaType: MediaType = .file
        if fileExtension == "MP4" {
            mediaType = .video
        }
        else if fileExtension == "PNG" {
            mediaType = .image
        }
        else {
            mediaType = .file
        }
        
        
        viewModel.publish(file: data, with: fileExtension, type: mediaType.rawValue)
    }
    
    func didCancel() {
        UIView.transition(with: blurView, duration: 0.4,
                          options: .curveEaseOut,
                          animations: {
                            self.blurView.isHidden = true
                          })
    }
    
    
}

