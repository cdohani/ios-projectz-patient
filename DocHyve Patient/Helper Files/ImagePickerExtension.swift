//
//  ImagePickerExtension.swift
//  PIC
//
//  Created by Adeel on 6/12/23.
//

import Foundation

import UIKit

extension UIViewController: @retroactive UIImagePickerControllerDelegate, @retroactive UINavigationControllerDelegate {
    
    func showImagePicker(completion: @escaping (UIImage?, String?) -> Void) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .overCurrentContext // or .overFullScreen

        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                // Handle the case where the camera is not available
                print("Camera not available")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)

        // Completion handler for the selected image
        imagePicker.completion = completion
    }

    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        var imageName: String?
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = pickedImage
        }
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            imageName = url.lastPathComponent
        }
        
        picker.dismiss(animated: true) {
            picker.completion?(image, imageName)
            picker.completion = nil
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.completion?(nil, nil)
            picker.completion = nil
        }
    }
}

private extension UIImagePickerController {
    struct AssociatedKeys {
        static var completionClosure = "completionClosure"
    }
    
    typealias ImagePickerCompletionClosure = (UIImage?, String?) -> Void
    
    var completion: ImagePickerCompletionClosure? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.completionClosure) as? ImagePickerCompletionClosure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.completionClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
