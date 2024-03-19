//
//  TSAuthorizationTool.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/29.
//
import UIKit
import AVFoundation
import Photos
struct TSAuthorizationTool {
    
    /// Camera access
    /// - Parameter isOpenAlert: Whether to open the guided missile window
    /// - Returns: Permission state
    static func isCameraAvailable(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isCameraDeviceAvailable(.front) && UIImagePickerController.isCameraDeviceAvailable(.rear) {
            return true
        }
        return false
    }
    
    
    ///  e whether the camera is supported
    /// - Parameter isOpenAlert: Whether to open the guided missile window
    /// - Returns: Permission state
    static func doesCameraSupportTakingPhotos(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        let mediaType = AVMediaType.video //Read media type
        let authStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        if authStatus == AVAuthorizationStatus.authorized || authStatus == AVAuthorizationStatus.notDetermined {
            return true
        }
        return false

    }
    
    ///  Album access
    /// - Parameter isOpenAlert: Whether to open the guided missile window
    /// - Returns: 权限状态
    static func isPhotoLibraryAvailable(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .authorized || authStatus == .notDetermined  {
            return true
        }
        if isOpenAlert  {
            
            let sheet = TSAlertSheetView()
            sheet.show(icon: nil, title:"The album access permission is not enabled".attributed , alignment: .center, leftTitle: "Cancel", rightTitle: "Go to Settings", cancelClosure: {
                completion?(false)
            }, rightClosure: {
                /// Permission state
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
        return false

    }
}

