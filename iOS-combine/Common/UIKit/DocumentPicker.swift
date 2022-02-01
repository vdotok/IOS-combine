//
//  DocumentPicker.swift
//  Chat-Demo-IOS
//
//  Created by usama farooq on 26/05/2021.
//

import Foundation
import UIKit

protocol DocumentPickerProtocol {
    func didPickDocument(document: Document?)
    func didTapdismiss()
}

class Document: UIDocument {
    var data: Data?
    
    override func contents(forType typeName: String) throws -> Any {
        guard  let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = data else { return }
        self.data = data
    }
}

class DocumentPicker: NSObject {
    private var picker: UIDocumentPickerViewController?
    private var presenetedViewController: UIViewController?
    private var delegate: DocumentPickerProtocol?
    
    private var pickedDocument: Document?
    
    init(viewController: UIViewController, delegate:DocumentPickerProtocol ) {
        super.init()
        self.presenetedViewController = viewController
        self.delegate = delegate
    }
    
    
    func displayPicker() {
        self.picker =  UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        guard let documentPicker = picker else {return }
        picker?.delegate = self
        presenetedViewController?.present(documentPicker, animated: true, completion:  nil)
        
    }
}

extension DocumentPicker : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        do {
            let resources = try myURL.resourceValues(forKeys:[.fileSizeKey])
            let fileSize = resources.fileSize!
            print ("\(fileSize)")
        } catch {
            print("Error: \(error)")
        }
        print("import result : \(myURL)")
        documentFromURL(pickedURL: myURL)
        delegate?.didPickDocument(document: pickedDocument)
    }
    
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        delegate?.didTapdismiss()
    }
    
    private func documentFromURL(pickedURL: URL) {
        
        /// start accessing the resource
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()

        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (readURL) in
            let document = Document(fileURL: readURL)
            pickedDocument = document
        }
    }
}
