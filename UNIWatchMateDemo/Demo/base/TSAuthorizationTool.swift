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
    
    /// 摄Camera access
    /// - Parameter isOpenAlert: Whether to open the guided missile window
    /// - Returns: Permission state
    static func isCameraAvailable(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isCameraDeviceAvailable(.front) && UIImagePickerController.isCameraDeviceAvailable(.rear) {
            return true
        }
        return false
    }
    
    
    ///  判断是否支持摄像
    /// - Parameter isOpenAlert: 是否打开引导弹窗
    /// - Returns: 权限状态
    static func doesCameraSupportTakingPhotos(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        let mediaType = AVMediaType.video //读取媒体类型
        let authStatus : AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        if authStatus == AVAuthorizationStatus.authorized || authStatus == AVAuthorizationStatus.notDetermined {
            return true
        }
        return false

    }
    
    ///  相册访问权限
    /// - Parameter isOpenAlert: 是否打开引导弹窗
    /// - Returns: 权限状态
    static func isPhotoLibraryAvailable(_ isOpenAlert : Bool = false , _ completion:CommonBoolBlock? = nil) -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .authorized || authStatus == .notDetermined  {
            return true
        }
        if isOpenAlert  {
            
            let sheet = TSAlertSheetView()
            sheet.show(icon: nil, title:"相册访问权限未开启".attributed , alignment: .center, leftTitle: "取消", rightTitle: "去设置", cancelClosure: {
                completion?(false)
            }, rightClosure: {
                /// 跳转到设置界面
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
        }
        return false

    }
}

