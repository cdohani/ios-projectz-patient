//
//  ImagePickerExtension.swift
//  PIC
//
//  Created by Adeel on 6/12/23.
//

import UIKit
import PhotosUI

//extension UIViewController: @retroactive UIImagePickerControllerDelegate, @retroactive UINavigationControllerDelegate {
//    
//    func showImagePicker(completion: @escaping (UIImage?, String?) -> Void) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//
//        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
//        alertController.modalPresentationStyle = .overCurrentContext // or .overFullScreen
//
//        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
//            imagePicker.sourceType = .photoLibrary
//            self.present(imagePicker, animated: true, completion: nil)
//        }
//
//        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                imagePicker.sourceType = .camera
//                self.present(imagePicker, animated: true, completion: nil)
//            } else {
//                // Handle the case where the camera is not available
//                print("Camera not available")
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        alertController.addAction(galleryAction)
//        alertController.addAction(cameraAction)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//
//        // Completion handler for the selected image
//        imagePicker.completion = completion
//    }
//
//    
//    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        var image: UIImage?
//        var imageName: String?
//        
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            image = pickedImage
//        }
//        
//        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
//            imageName = url.lastPathComponent
//        }
//        
//        picker.dismiss(animated: true) {
//            picker.completion?(image, imageName)
//            picker.completion = nil
//        }
//    }
//    
//    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true) {
//            picker.completion?(nil, nil)
//            picker.completion = nil
//        }
//    }
//}
//
//private extension UIImagePickerController {
//    struct AssociatedKeys {
//        static var completionClosure = "completionClosure"
//    }
//    
//    typealias ImagePickerCompletionClosure = (UIImage?, String?) -> Void
//    
//    var completion: ImagePickerCompletionClosure? {
//        get {
//            return objc_getAssociatedObject(self, &AssociatedKeys.completionClosure) as? ImagePickerCompletionClosure
//        }
//        set {
//            objc_setAssociatedObject(self, &AssociatedKeys.completionClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//    }
//}

extension UIViewController: @retroactive UIImagePickerControllerDelegate, @retroactive UINavigationControllerDelegate {
    
    func showImagePicker(allowsMultipleSelection: Bool = false, completion: @escaping ([UIImage]?, [String]?) -> Void) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .overCurrentContext // or .overFullScreen
        
        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { _ in
            if #available(iOS 14, *), allowsMultipleSelection {
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 0 // 0 means unlimited selection
                configuration.filter = .images
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                objc_setAssociatedObject(self, &AssociatedKeys.pickerCompletion, completion, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                self.present(picker, animated: true, completion: nil)
            } else {
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(galleryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        imagePicker.completion = completion
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image: UIImage?
        var imageName: String?
        
        if let pickedImage = info[.originalImage] as? UIImage {
            image = pickedImage
        }
        
        if let url = info[.imageURL] as? URL {
            imageName = url.lastPathComponent
        }
        
        picker.dismiss(animated: true) {
            picker.completion?([image].compactMap { $0 }, [imageName].compactMap { $0 })
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

@available(iOS 14, *)
extension UIViewController: @retroactive PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let completion = objc_getAssociatedObject(self, &AssociatedKeys.pickerCompletion) as? ([UIImage]?, [String]?) -> Void
        
        var images: [UIImage] = []
        var imageNames: [String] = []
        
        let group = DispatchGroup()
        
        for result in results {
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    images.append(image)
                }
                if let identifier = result.itemProvider.suggestedName {
                    imageNames.append(identifier)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion?(images, imageNames)
        }
    }
}

private extension UIImagePickerController {
    struct AssociatedKeys {
        static var completionClosure = "completionClosure"
    }
    
    typealias ImagePickerCompletionClosure = ([UIImage]?, [String]?) -> Void
    
    var completion: ImagePickerCompletionClosure? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.completionClosure) as? ImagePickerCompletionClosure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.completionClosure, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private struct AssociatedKeys {
    static var pickerCompletion = "pickerCompletion"
}
