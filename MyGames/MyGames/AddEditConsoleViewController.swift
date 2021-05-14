//
//  AddEditConsoleViewController.swift
//  MyGames
//
//  Created by Pedro Barbosa on 10/05/21.
//

import UIKit
import Photos

class AddEditConsoleViewController: UIViewController {
    
    // MARK: - Properties
    var console: Console!
    
    @IBOutlet weak var tfPlatform: UITextField!
    @IBOutlet weak var btAddEditConsole: UIButton!
    @IBOutlet weak var btCoverConsole: UIButton!
    @IBOutlet weak var ivCoverConsole: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ConsolesManager.shared.loadConsoles(with: context)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareDataLayout()
    }
    
    // MARK: - Helpers
    private func prepareDataLayout() {
        if console != nil {
            title = "Editar console"
            btAddEditConsole.setTitle("ALTERAR", for: .normal)
            tfPlatform.text = console.name
            ivCoverConsole.image = console.thumbnail as? UIImage
            
            if console.thumbnail != nil {
                btCoverConsole.setTitle(nil, for: .normal)
            }
        }
    }
    
    func chooseImageFromLibrary(sourceType: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            let consoleImagePicker = UIImagePickerController()
            consoleImagePicker.sourceType = sourceType
            consoleImagePicker.delegate = self
            consoleImagePicker.allowsEditing = false
            consoleImagePicker.navigationBar.tintColor = UIColor(named: "main")
            
            self.present(consoleImagePicker, animated: true, completion: nil)
        }
    }
    
    func selectPicture(sourceType: UIImagePickerController.SourceType) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.chooseImageFromLibrary(sourceType: sourceType)
                } else {
                    print("unauthorized -- TODO message")
                }
            })
        } else if photos == .authorized {
            self.chooseImageFromLibrary(sourceType: sourceType)
        }
    }
    
    // MARK: - Actions
    @IBAction func AddEditConsoleImage(_ sender: UIButton) {
        let alert = UIAlertController(title: "Selecinar capa", message: "De onde você quer escolher a capa?", preferredStyle: .actionSheet)
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        })
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Album de fotos", style: .default, handler: {(action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        })
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func AddEditConsole(_ sender: UIButton) {
        if console == nil {
            console = Console(context: context)
        }
        console.name = tfPlatform.text
        console.thumbnail = ivCoverConsole.image
        
        do {
            try context.save()
            ConsolesManager.shared.loadConsoles(with: context)
        } catch {
            print(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension AddEditConsoleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.ivCoverConsole.image = pickedImage
                self.ivCoverConsole.setNeedsDisplay()
                self.btCoverConsole.setTitle(nil, for: .normal)
                self.btCoverConsole.setNeedsDisplay()
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
