//
//  ViewController.swift
//  movor
//
//  Created by Elizabeth Saltykova on 26.11.2020.
//

import UIKit
import Photos
import AssetsLibrary

class GalleryViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet private weak var galleryButton: UIButton!
    @IBOutlet private weak var uploadButton: UIButton!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var progressBar: UIProgressView!
    
    //MARK: - Private
    
    private var imagePickerController = UIImagePickerController()
    
    private var sessionManager: SessionManager?
    
    private var assetURL: URL?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - IBActions
    
    @IBAction private func galleryDidTap(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func uploadDidTap(_ sender: Any) {
        guard let url = assetURL else {
            return
        }
        sessionManager?.upload(fromFile: url)
    }
    
    //MARK: - Private
    
    private func configureUI() {

        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
        
        sessionManager = SessionManager()
        guard let url = URL(string: " http://192.168.138.29:8099/media-service/upload") else {
            return
        }
        sessionManager?.startSession(endpoint: url, { (error) in
            if let error = error {
                statusLabel.text = error.localizedDescription
            }
            sessionManager?.progress =  { (_ bytesWritten: __int64_t, _ bytesTotal: __int64_t) in
                self.progressBar.progress = Float(bytesWritten/bytesTotal)
            }
            
            sessionManager?.failure = { error in
                self.statusLabel.text = error.localizedDescription
            }
            
            sessionManager?.result = { url in
                self.statusLabel.text = "Success"
            }
        })
    }

}
extension GalleryViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
        assetURL = info[UIImagePickerController.InfoKey.referenceURL] as! URL
    }
}

