//
//  APPCommonLibraryService.swift
//  UNIWatchMateDemo
//

import Foundation
import Photos
import UIKit

class APPCommonLibraryService: NSObject {
    
    static let shared = APPCommonLibraryService()
    
    var curPhotoElementCount = 0
    var lastReceiveImgTime = 0
    var curImageData = Data()
    var curPhotoElementIndex = 0
    
    weak var delegate: APPPhotoLibraryDelegate?
    
    private override init() {
        super.init()
        WatchManager.sharedInstance().current.subscribeNext { [weak self] peripheral in
            peripheral?.photoLibraryDelegate = self
            peripheral?.apps.photoLibraryApp.delegate = self
        }
    }
    
    func setAPPPhotoLibraryDelegate(delegate: APPPhotoLibraryDelegate?) {
        self.delegate = delegate
    }
}

// MARK: - 无存储方案：分片拉取照片

extension APPCommonLibraryService {
    fileprivate func startReceiveImg() {
        if curPhotoElementCount > 0 {
            DDLogInfo("APPCommonLibraryService letDeviceSendPhotoElement curPhotoElementIndex = \(curPhotoElementIndex)")
            letDeviceSendPhotoElement(elementIndex: curPhotoElementIndex) { [weak self] rs in
                guard let self = self else {
                    DDLogInfo("APPCommonLibraryService startReceiveImg letDeviceSendPhotoElement self is nil")
                    return
                }
                if rs != 0 {
                    DDLogInfo("APPCommonLibraryService letDeviceSendPhotoElement rs != 0")
                    stopImport()
                }
            }
        }
    }
    
    func stopImport() {
        curImageData.removeAll(keepingCapacity: true)
        curPhotoElementCount = 0
        curPhotoElementIndex = 0
        SJHud.dismiss()
        letDeviceEndReceiveState()
    }
    
    func letDeviceEndReceiveState() {
        let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        
        photoLibraryApp.letDeviceEndReceiveState().subscribeNext { [weak self] rs in
            DDLogInfo("APPCommonLibraryService photoLibraryApp letDeviceEndReceiveState rs \(String(describing: rs)) ")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SJHud.dismiss()
            }
            guard self != nil else { return }
        } error: { error in
            guard let errorMsg = error?.localizedDescription else { return }
            DDLogInfo("APPCommonLibraryService letDeviceEndReceiveState \(errorMsg) ")
            SJHud.dismiss()
        } completed: {
        }
    }
    
    func letDeviceSendPhotoElement(elementIndex: Int, callBack: CommonIntBlock?) {
        let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.letDeviceSendPhoto(elementIndex).subscribeNext { [weak self] rs in
            DDLogInfo("APPCommonLibraryService photoLibraryApp letDeviceSendPhoto rs \(String(describing: rs)) ")
            guard self != nil else {
                DDLogInfo("APPCommonLibraryService letDeviceSendPhoto self is nil ")
                return
            }
            callBack?(rs as? Int)
        } error: { error in
            guard let errorMsg = error?.localizedDescription else { return }
            DDLogInfo("APPCommonLibraryService letDeviceSendPhoto \(errorMsg) ")
            callBack?(1)
        } completed: {
        }
    }
}

// MARK: - WMPhotoLibraryAppDelegate

extension APPCommonLibraryService: WMPhotoLibraryAppDelegate {
    func deviceTakePhotoElementCount(_ elementCount: Int) {
        // 无存储方案：分片数量
        self.curPhotoElementCount = elementCount
        self.curPhotoElementIndex = 1
        SJHud.showLoading(text: "photo_receiving_loading".localized())
        startReceiveImg()
    }
}

// MARK: - WMPhotoLibraryDelegate

extension APPCommonLibraryService: WMPhotoLibraryDelegate {
    
    func glassesSendImage(withImageData imageData: Data?) {
        delegate?.appPhotoLibraryDidReceiveImage?(imageData)
        guard let imageElementData = imageData else {
            DDLogInfo("APPCommonLibraryService 收到图片 result 为 nil")
            return
        }
        if curPhotoElementCount <= 0 {
            DDLogInfo("APPCommonLibraryService 收到图片 但 curPhotoElementCount = \(curPhotoElementCount)")
            return
        }
        curImageData.append(imageElementData)
        
        if curPhotoElementIndex < curPhotoElementCount {
            DDLogInfo("APPCommonLibraryService 分片接收中 \(curPhotoElementIndex) < \(curPhotoElementCount)")
            curPhotoElementIndex += 1
            startReceiveImg()
            return
        }
        
        curPhotoElementCount = 0
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let dateTimeString = dateFormatter.string(from: currentDate)
        let peripheral = WatchManager.sharedInstance().currentValue
        let product = peripheral.target.product ?? ""
        let photoName = "\(product)-\(dateTimeString).jpeg"
        
        // 与 PhotoLibraryViewModel 导入保存路径一致：`Documents/deviceImg/<文件名>`
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let deviceImgPath = documentsPath.appendingPathComponent("deviceImg")
            try? FileManager.default.createDirectory(at: deviceImgPath, withIntermediateDirectories: true)
            
            let finalImageUrl = deviceImgPath.appendingPathComponent(photoName)
            
            do {
                if FileManager.default.fileExists(atPath: finalImageUrl.path) {
                    try FileManager.default.removeItem(at: finalImageUrl)
                }
                try curImageData.write(to: finalImageUrl)
                DDLogInfo("APPCommonLibraryService 原图已保存: \(finalImageUrl.path)")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.receiveNewPhoto?(finalImageUrl)
                    self.resetReceiveBuffersOnly()
                    SJHud.dismiss()
                    self.saveToPhotoLibraryAndNotify(imageUrl: finalImageUrl, photoName: photoName)
                }
            } catch {
                DDLogError("APPCommonLibraryService 保存原图失败: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.stopImport()
                }
            }
            
            let timestampMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
            DDLogDebug("APPCommonLibraryService lastImgCostTime: \(timestampMilliseconds - lastReceiveImgTime)")
            lastReceiveImgTime = timestampMilliseconds
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.stopImport()
            }
        }
    }
    
    /// 清空缓冲与计数，不弹 HUD、不通知设备（由 save 完成后统一 letDeviceEndReceiveState）
    private func resetReceiveBuffersOnly() {
        curImageData.removeAll(keepingCapacity: true)
        curPhotoElementCount = 0
        curPhotoElementIndex = 0
    }
    
    func glassesSendImageNames(_ imageNamesData: Data?) {
        DDLogInfo("APPCommonLibraryService: 收到图片名称数据")
        delegate?.appPhotoLibraryDidReceiveImageNames?(imageNamesData)
    }
    
    /// 保存到系统相册，成功后 toast 提示去相册查看
    private func saveToPhotoLibraryAndNotify(imageUrl: URL, photoName: String) {
        guard let image = UIImage(contentsOfFile: imageUrl.path) else {
            DDLogError("APPCommonLibraryService 无法加载图片用于保存到相册")
            finishDeviceReceiveAfterSave(showToast: "photo_save_failed".localized())
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            let allowed = status == .authorized  //|| status == .limited
            guard allowed else {
                DispatchQueue.main.async {
                    self.finishDeviceReceiveAfterSave(showToast: "photo_album_permission_denied".localized())
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        DDLogInfo("APPCommonLibraryService 图片保存到相册成功: \(photoName)")
                        self.finishDeviceReceiveAfterSave(showToast: "photo_saved_check_album".localized())
                    } else {
                        DDLogError("APPCommonLibraryService 图片保存到相册失败: \(error?.localizedDescription ?? "")")
                        self.finishDeviceReceiveAfterSave(showToast: "photo_save_failed".localized())
                    }
                }
            }
        }
    }
    
    /// 通知设备结束发送状态，并可选展示结果 toast
    private func finishDeviceReceiveAfterSave(showToast: String?) {
        let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.letDeviceEndReceiveState().subscribeNext { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let t = showToast {
                    SJHud.showText(status: t, delay: 2.5)
                }
            }
        } error: { _ in
            DispatchQueue.main.async {
                if let t = showToast {
                    SJHud.showText(status: t, delay: 2.5)
                }
            }
        } completed: {
        }
    }
}
