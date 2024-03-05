//
//  UIViewController+Ext.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/10/23.
//

import Foundation
import UIKit
import Photos

public protocol PropertyStoring {
    
    associatedtype T
    associatedtype AlbumT
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: AlbumT) -> AlbumT
}

public extension PropertyStoring {
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: AlbumT) -> AlbumT {
        guard let value = objc_getAssociatedObject(self, key) as? AlbumT else {
            return defaultValue
        }
        return value
    }
}

extension UIViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate, PropertyStoring {
    
    public typealias T = String
    public typealias AlbumT = Int
    private struct CustomProperties {
        static var imgType = UIImagePickerController.InfoKey.originalImage
        static var isAlbum = UIImagePickerController.SourceType.photoLibrary
    }
    var imgType: String {
        get {
            return getAssociatedObject(&CustomProperties.imgType, defaultValue: CustomProperties.imgType.rawValue)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.imgType, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var albumType: Int {
        get {
            return getAssociatedObject(&CustomProperties.isAlbum, defaultValue: CustomProperties.isAlbum.rawValue)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.isAlbum, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    /// 获取系统相机是否打开
    /// - Parameter completion: true  /false
    func isAuthorizationCamera(completion:CommonBoolBlock?) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { isOpen in
                DispatchQueue.main.async {
                    completion?(isOpen)
                }
            }
        }else if status == .authorized {
            completion?(true)
        }else{
            completion?(false)
//            self.openCameraAlertView()
        }
    }
    
    /// 获取系统相册是否打开
    /// - Parameter completion: true  /false
    func isAuthorizationPhoto(completion:CommonBoolBlock?) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) {state in
                    DispatchQueue.main.async {
                        if state == .authorized || state == .limited {
                            completion?(true)
                        }
                    }
                }
            }else if status == .authorized || status == .limited {
                completion?(true)
            }else{
//                self.openPhotoAlertView()
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { state in
                    DispatchQueue.main.async {
                        if state == .authorized {
                            completion?(true)
                        }
                    }
                }
            }else if status == .authorized {
                completion?(true)
            }else{
//                self.openPhotoAlertView()
            }
        }
    }
    
//    private func openPhotoAlertView() {
//        let sheet = R.nib.tsAlertSheetView(owner: nil)!
//        sheet.show(icon: nil, title: R.string.tips.相册访问权限未开启().attributed, alignment: .center, leftTitle: R.string.cusButton.取消(), rightTitle: R.string.cusButton.去设置()) {
//            
//        } rightClosure: {
//            TSBLEPermissions.shared.openAppSettings()
//        }
//    }
//
//    private func openCameraAlertView() {
//        let sheet = R.nib.tsAlertSheetView(owner: nil)!
//        sheet.show(icon: nil, title: R.string.tips.摄像头权限未开启().attributed, alignment: .center, leftTitle: R.string.cusButton.取消(), rightTitle: R.string.cusButton.去设置()) {
//            
//        } rightClosure: {
//            TSBLEPermissions.shared.openAppSettings()
//        }
//    }
    
//    private func startOpenPhotos() {
//        if self.albumType == UIImagePickerController.SourceType.photoLibrary.rawValue {
//            self.invokeSystemPhoto()
//        }else {
//            self.invokeSystemCamera()
//        }
//    }

    
    /// 打开系统相册
    /// - Returns: 是否有相册权限
     @discardableResult
    func invokeSystemPhoto() -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            if self.imgType == UIImagePickerController.InfoKey.editedImage.rawValue {
                imagePickerController.allowsEditing = true
            }else {
                imagePickerController.allowsEditing = false
            }
            self.present(imagePickerController, animated: true, completion: nil)
            
            return true
        }else {
            return false
        }
    }

    /// 打开系统相机拍照
    /// - Returns: 是否有相机权限
    @discardableResult
    func invokeSystemCamera() -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            imagePickerController.cameraCaptureMode = .photo
            imagePickerController.mediaTypes = ["public.image"]
            
            self.imgType = UIImagePickerController.InfoKey.originalImage.rawValue
            
            self.present(imagePickerController, animated: true, completion: nil)
         
            return true
        }else {
            return false
        }
    }
    
    @objc public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.view.isUserInteractionEnabled = false
        
        picker.dismiss(animated: true, completion: {
            
            let img: Any = info[UIImagePickerController.InfoKey(rawValue: self.imgType)] as Any
            if (img is UIImage) {
                if self.albumType == UIImagePickerController.SourceType.photoLibrary.rawValue {
                    self.reloadViewWithImg(img: img as! UIImage)
                }else {
                    self.reloadViewWithCameraImg(img: img as! UIImage)
                }
            }else { }
        })
    }
    
    @objc func reloadViewWithImg(img: UIImage) -> Void {
        
    }
    
    @objc func reloadViewWithCameraImg(img: UIImage) -> Void {
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
//        if #available(iOS 11.0, *) {
//            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
//        }
        self.dismiss(animated: true, completion: nil)
    }
}
