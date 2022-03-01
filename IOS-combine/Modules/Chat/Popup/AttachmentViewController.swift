//
//  AttachmentViewController.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 26/05/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import UIKit
enum SensorType {
    case heartBeat
    case stepCount
    case oxygenLevel
}

protocol AttachmentPickerDelegate: AnyObject {
    func didSend(sensorType: SensorType)
    func didCancel()
}

class AttachmentViewController: UIViewController {
    
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mainTitle: UILabel!
    weak var delegate: AttachmentPickerDelegate?
   lazy var imagePicker: ImagePicker = ImagePicker(presentationController: self, delegate: self)
    lazy var documentPicker = DocumentPicker(viewController: self, delegate: self)
    
    @IBAction func didTapCross(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        delegate?.didCancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(_:)))
        // Do any additional setup after loading the view.
        tapView.addGestureRecognizer(tapToDismiss)
        containerView.layer.cornerRadius = 8
        mainTitle.font = UIFont(name: "Poppins-SemiBold", size: 14)
        mainTitle.textColor = .appGreyColor
        
    }
    @objc func tapToDismiss(_ recognizer: UITapGestureRecognizer) {
        
       self.dismiss(animated: true, completion: nil)
        delegate?.didCancel()
      
    }
    
    
    @IBAction func didStepCount(_ sender: UIButton) {
        delegate?.didSend(sensorType: .stepCount)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOxygen(_ sender: UIButton) {
        delegate?.didSend(sensorType: .oxygenLevel)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapHeartBeat(_ sender: UIButton) {
        delegate?.didSend(sensorType: .heartBeat)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapAlbum(_ sender: UIButton) {
        imagePicker.action(for: .photoLibrary)
    }
    
    @IBAction func didTapCamera(_ sender: UIButton) {
        imagePicker.action(for: .camera)
    }
    
    @IBAction func didTapFile(_ sender: UIButton) {
        documentPicker.displayPicker()
    }
 }

extension AttachmentViewController:ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        if let image = image {
            let jpegData = image.jpegData(compressionQuality: 0.2)
            guard let data = jpegData else {return}
        //    delegate?.didSelectImage(data: data)
        }
    }
    
}

extension AttachmentViewController: DocumentPickerProtocol {
    func didTapdismiss() {
        delegate?.didCancel()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func didPickDocument(document: Document?) {
        if let pickedDoc = document {
            let fileURL = pickedDoc.fileURL
            let fileName = (fileURL.absoluteString as NSString).lastPathComponent
            let fileExtn = fileName.components(separatedBy: ".")[1]
            let documentData: Data = try! Data(contentsOf: fileURL)
            print("There were \(documentData.count) bytes")
            if documentData.count > 6291456 {
                ProgressHud.showError(message: "File should be 6MBs", viewController: self)
                return
            }
          //  delegate?.didSelectDocument(data: documentData, fileExtension: fileExtn)
        }
    }
    
}
