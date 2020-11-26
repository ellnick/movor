//
//  ViewController.swift
//  movor
//
//  Created by Elizabeth Saltykova on 26.11.2020.
//

import UIKit

class GalleryViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK: - Outlets
    
    @IBOutlet private weak var galleryButton: UIButton!
    @IBOutlet private weak var uploadButton: UIButton!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var progressBar: UIProgressView!
    
    //MARK: - Private
    
    private var imagePickerController = UIImagePickerController()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - IBActions
    
    @IBAction private func galleryDidTap(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction private func uploadDidTap(_ sender: Any) {
        
    }
    
    //MARK: - Private
    
    private func configureUI() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePickerController.allowsEditing = true
    }

}
extension GalleryViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Selected Media
    }
}

