//
//  ImagePicker.swift
//  IOS-combine
//
//  Created by usama farooq on 01/09/2021.
//  Copyright © 2021 VDOTOK. All rights reserved.
//

import Foundation
import UIKit

public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
//        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

     func action(for type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return
        }
        
        self.pickerController.sourceType = type
        self.presentationController?.present(self.pickerController, animated: true, completion: nil)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        return self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}
