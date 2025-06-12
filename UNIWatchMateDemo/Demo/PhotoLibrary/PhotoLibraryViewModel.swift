//
//  PhotoLibraryViewModel.swift
//  LensMoo
//
//  Created by abel on 2025/5/7.
//  Copyright © 2025 LensMoo. All rights reserved.
//

import RxRelay
import Photos
import RxSwift
import SVProgressHUD

class PhotoLibraryViewModel : NSObject {
    
    var deviceFileNameList = BehaviorRelay<[String]>(value: [])
    var phoneImgUrlFromDevice = BehaviorRelay<[URL]>(value: [])
    var importingPhoto = BehaviorRelay<Bool>(value: false)
    var photoCount = BehaviorRelay<Int>(value: 0)

    var realPhotoCount = 0
    var curImageData = Data()

    var importingIndex = BehaviorRelay<Int>(value: 0)
    
    var curPhotoElementIndex = 0
    var curPhotoElementCount = 0
    var lastReceiveImgTime = 0
    weak var selfVc: PhotoLibraryController?
    
    
    init(vc: PhotoLibraryController) {
        selfVc = vc
        super.init()
       
        WatchManager.sharedInstance().current.subscribeNext {[weak self] peripheral in
            peripheral?.photoLibraryDelegate = self
        }
//        SJWMPeripheralManager.share.rac_peripheral.subscribeNext {[weak self] peripheral in
//            peripheral?.aiAssistantDelegate = self
//        }
        self.addNotice()
    }
    
    func addNotice() {
        }
    

    
    fileprivate func startReceiveImg() {
        let photoNameList = deviceFileNameList.value
        
        if importingIndex.value >= photoNameList.count{
            if importingPhoto.value {
                SVProgressHUD.showSuccess(withStatus: "导入完成".localized())

            }
            stopImport()
        }else {
            let photoName = photoNameList[importingIndex.value]
            if curPhotoElementCount > 0 {
                DDLogInfo("letDeviceSendPhotoElement curPhotoElementIndex = \(curPhotoElementIndex)")
                letDeviceSendPhotoElement(elementIndex: curPhotoElementIndex){  [weak self] rs in
                    guard let self = self else {
                        return
                    }
                    if rs != 0 {
                        DDLogInfo("letDeviceSendPhotoElement rs != 0")
                        stopImport()
                    }
                }
            }else {
                getDevicePhotoElementCount(name: photoName){  [weak self] rs in
                    guard let self = self else {
                        return
                    }
                    curImageData.removeAll(keepingCapacity: true)
                    curPhotoElementCount = rs ?? 0
                    if curPhotoElementCount < 1 {
                        DDLogInfo("getDevicePhotoElementCount is 0")
                        stopImport()
                        return
                    }
                    curPhotoElementIndex = 1
                    startReceiveImg()
                }
            }
          
        }
    }
    
    func startImport(){
      
        //循环的去下载图片
        SJHud.showLoading(text: nil)
        letDeviceSendFileNames(){[weak self] rs in
            SJHud.dismiss()
            guard let self = self else {
                return
            }
            guard  rs == 0 else {
                DDLogInfo("没有可用的图片名称")
                if rs == 2 {
                    SJHud.showText(status: "device_fail_busy")
                }else{
                    SJHud.showText(status: "no_photo_import")
                }
                return
            }
        
            //TODO 需要超时恢复状态，结束设备 发送相册 状态
        }
    }
    
    func stopImport(_ letDeviceEnd:Bool = true, manualOperation:Bool = false){
        curImageData.removeAll(keepingCapacity: true)
        curPhotoElementCount = 0
        curPhotoElementIndex = 0
        importingIndex.accept(0)
        importingPhoto.accept(false)
        if letDeviceEnd{
            if manualOperation {
                SJHud.showLoading(text: nil)
            }
            letDeviceEndReceiveState()
        }
        photoCount.accept(photoCount.value)

    }
    
    func getDevicePhotoCount(){
//        if isSync == true {
//            return
//        }
//        guard let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp else {
//            return
//        }
//        photoLibraryApp.getOnlyDevicePhotoNamesCount().subscribeNext { [weak self] rs in
//            DDLogInfo("photoLibraryApp getOnlyDevicePhotoNames rs \(String(describing: rs)) ")
//            guard let self = self else {return}
//            
//            self.photoCount.accept(rs as? Int ?? 0)
//        } error: { error in
//            guard let errorMsg = error?.localizedDescription else {return}
//            DDLogInfo("photoLibraryApp getOnlyDevicePhotoNames \(errorMsg) ")
//            
//        } completed: {
//            
//        }
    }
    
    func letDeviceSendFileNames(callback:CommonIntBlock?){
      
         let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.letDeviceSendFileNames().subscribeNext { [weak self] rs in
            //这个有可能比图片数量来的迟的
            DDLogInfo("photoLibraryApp letDeviceSendFileNames rs \(String(describing: rs)) ")
            guard self != nil else {return}
           
            callback?(rs as? Int ?? 1)
        } error: { error in
            callback?(2)
            guard let errorMsg = error?.localizedDescription else {return}
            DDLogInfo("letDeviceSendFileNames \(errorMsg) ")
            
        } completed: {
            
        }
    }
    func getDevicePhotoElementCount(name:String,callBack:CommonIntBlock?){
        
         let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.getDevicePhotoElementCount(name).subscribeNext { [weak self] rs in
            DDLogInfo("photoLibraryApp getDevicePhotoElementCount rs \(String(describing: rs))  name :\(name)")
            guard self != nil else {return}
            callBack?(rs as? Int)
        } error: { error in
            guard let errorMsg = error?.localizedDescription else {return}
            DDLogInfo("getDevicePhotoElementCount \(errorMsg) ")
            callBack?(0)
        } completed: {
            
        }
    }
    
    func letDeviceSendPhotoElement(elementIndex:Int,callBack:CommonIntBlock?){
      
         let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.letDeviceSendPhoto(elementIndex).subscribeNext { [weak self] rs in
            DDLogInfo("photoLibraryApp letDeviceSendPhoto rs \(String(describing: rs)) ")
            guard self != nil else {return}
            callBack?(rs as? Int)
        } error: { error in
            guard let errorMsg = error?.localizedDescription else {return}
            DDLogInfo("letDeviceSendPhoto \(errorMsg) ")
            callBack?(1)
        } completed: {
            
        }
    }
    
    func letDeviceDeletePhoto(names:[String],callBack:CommonBoolBlock?){
      
        
        // 从phoneImgUrlFromDevice中删除names包含的文件
        phoneImgUrlFromDevice.accept( phoneImgUrlFromDevice.value.filter { url in
            let fileName = url.lastPathComponent
            return !names.contains(fileName)
        })
        var count = photoCount.value
        count =  count - names.count
        if count < 0 {
            count = 0
        }
        photoCount.accept(count)
        
        // 递归删除照片
        deletePhotoRecursively(names: names, index: 0) { success in
            callBack?(success)
        }
    }
    
    /// 递归删除照片，每次删除一张
    private func deletePhotoRecursively(names: [String], index: Int, completion: @escaping (Bool) -> Void) {
        // 如果所有照片都已删除，则返回成功
        if index >= names.count {
            completion(true)
            return
        }
        
         let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        DDLogInfo("deletePhotoRecursively index =\(index)")

        // 每次只删除一张照片
        let singleName = [names[index]]
        photoLibraryApp.letDeviceDeletePhoto(singleName).subscribeNext { [weak self] rs in
            DDLogInfo("photoLibraryApp letDeviceDeletePhoto rs \(String(describing: rs)) 正在删除第 \(index+1)/\(names.count) 张")
            guard let self = self else {
                completion(false)
                return
            }
            
            if rs == 2 {
                DDLogInfo("device_fail_busy")
                completion(false)
            } else if rs == 1 {
                DDLogInfo("fail_del_of_device")
                completion(false)
            } else if rs == 0 {
                // 删除成功，继续删除下一张
                if index == names.count - 1 {
                    // 所有照片都已删除成功
                    completion(true)
                } else {
                    // 继续删除下一张
                    self.deletePhotoRecursively(names: names, index: index + 1, completion: completion)
                }
            }else{
                DDLogError("rs 不合法")
            }
        } error: { [weak self] error in
            guard let errorMsg = error?.localizedDescription else {
                completion(false)
                return
            }
            DDLogInfo("letDeviceDeletePhoto \(errorMsg) ")
            completion(false)
        } completed: {
            
        }
    }
    
    func letDeviceEndReceiveState(){
        
         let photoLibraryApp = WatchManager.sharedInstance().currentValue.apps.photoLibraryApp
        photoLibraryApp.letDeviceEndReceiveState().subscribeNext { [weak self] rs in
            DDLogInfo("photoLibraryApp letDeviceEndReceiveState rs \(String(describing: rs)) ")
            DispatchQueue.main.asyncAfter(deadline: .now()+1){
                SJHud.dismiss()
            }
            guard self != nil else {return}
        } error: { error in
            guard let errorMsg = error?.localizedDescription else {return}
            DDLogInfo("letDeviceEndReceiveState \(errorMsg) ")
            SJHud.dismiss()
            
        } completed: {
            
        }
    }
    
}

//相册SDK回调
extension PhotoLibraryViewModel: WMPhotoLibraryDelegate {
    
    func glassesSendImageNames(_ imageNamesData: Data?) {
        guard  imageNamesData != nil else {return}
        let imageNames = String(data: imageNamesData!, encoding: .utf8)?.trimmingCharacters(in: CharacterSet(charactersIn: "\0"))
        DDLogInfo("收到图片名称：\(String(describing: imageNames))")
        guard imageNames != nil ,!imageNames!.isEmpty else {
            DDLogInfo("收到图片名称：为空")
            SJHud.showText(status: "no_photo_import")
            stopImport()
            return
        }
    
        let namesArray = imageNames!.components(separatedBy: "|")
        DDLogInfo("收到图片名称数量：\(namesArray.count)")
        // 将 phoneImgUrlFromDevice 中的 URL 转换为文件名进行比较
        let existingFileNames = phoneImgUrlFromDevice.value.map { url -> String in
            let fileName = url.lastPathComponent
            return fileName // 移除所有扩展名
        }
        let names = namesArray.filter { !existingFileNames.contains($0) }
        
        if names.isEmpty {
            SJHud.showText(status:"no_photo_import")
            stopImport()
            photoCount.accept(photoCount.value)
            return
        }
        importingPhoto.accept(true)
        importingIndex.accept(0)
        self.deviceFileNameList.accept(names)

        startReceiveImg()
        let timestampMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
        lastReceiveImgTime = timestampMilliseconds
    }
    
    func glassesSendImage(withImageData imageData: Data?) {
        DDLogInfo("收到图片 curPhotoElementIndex = \(curPhotoElementIndex)")
        guard let imageElementData = imageData else{
            DDLogInfo("收到图片 result 为 nil")
            return
        }
        if curPhotoElementCount <= 0 {
            DDLogInfo("收到图片 但是 curPhotoElementCount =\(curPhotoElementCount)")
            return
        }
        curImageData.append(imageElementData)
        
        if curPhotoElementIndex < curPhotoElementCount  {
            DDLogInfo("curPhotoElementIndex < curPhotoElementCount : \(curPhotoElementIndex) < \(curPhotoElementCount)")
            curPhotoElementIndex += 1
            startReceiveImg()
            return
        }
        // 检查文件头部信息（以 JPEG 为例）
          if curImageData.count > 2 {
              let header = curImageData.prefix(2).map { String(format: "%02X", $0) }.joined()
              DDLogInfo("文件头: \(header)") // JPEG 应该是 FFD8
          }
          
          // 检查文件尾部信息
          if curImageData.count > 2 {
              let footer = curImageData.suffix(2).map { String(format: "%02X", $0) }.joined()
              DDLogInfo("文件尾: \(footer)") // JPEG 应该是 FFD9
          }
        curPhotoElementCount = 0
        let photoNameList = deviceFileNameList.value
        if importingIndex.value < photoNameList.count {
            let photoName = "\(photoNameList[importingIndex.value])"
            
            // 1. 保存到应用私有目录
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let deviceImgPath = documentsPath.appendingPathComponent("deviceImg")
                
                // 创建deviceImg目录（如果不存在）
                try? FileManager.default.createDirectory(at: deviceImgPath, withIntermediateDirectories: true)
                
                let imageUrl = deviceImgPath.appendingPathComponent(photoName)
                do {
                    try curImageData.write(to: imageUrl)
                    DDLogInfo("图片已保存到私有目录: \(imageUrl.path)")
                   var urlList = phoneImgUrlFromDevice.value
                    urlList.append(imageUrl)
                    phoneImgUrlFromDevice.accept(urlList)
                } catch {
                    DDLogInfo("保存图片到私有目录失败: \(error.localizedDescription)")
                }
                let timestampMilliseconds = Int(Date().timeIntervalSince1970 * 1000)
                
                DDLogDebug("lastImgCostTime :  \(timestampMilliseconds - lastReceiveImgTime)")
                lastReceiveImgTime = timestampMilliseconds
            }
            if( UserDefaults.standard.bool(forKey: "PhotoLibraryAutoSave")){
                // 2. 保存到相册
                if let image = UIImage(data: curImageData) {
                    PHPhotoLibrary.requestAuthorization { status in
                        if status == .authorized {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAsset(from: image)
                            }) { success, error in
                                if success {
                                    DDLogInfo("图片保存成功: \(photoName)")
                                    DispatchQueue.main.async {
//                                        self.selfVc?.view.makeToast("已保存第\(self.importingIndex.value )张图片到相册")
                                    }
                                } else {
                                    DDLogInfo("图片保存失败: \(error?.localizedDescription ?? "")")
                                }
                            }
                        } else {
                            DDLogInfo("相册权限未授权")
                        }
                    }
                }
            }
//            self.curImg.accept(UIImage(data: imageData))
            self.importingIndex.accept(importingIndex.value + 1)
            self.startReceiveImg()
        }else {
            DDLogInfo("index 错误 importingIndex = \(importingIndex)  photoNameList count = \(photoNameList.count)")
        }
    }
    
}
// 本地图片
extension PhotoLibraryViewModel {
    
    func getDeviceImagePath(fileName: String) -> URL? {
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let deviceImgPath = documentsPath.appendingPathComponent("deviceImg")
            return deviceImgPath.appendingPathComponent(fileName)
        }
        return nil
    }
    
    /// 获取设备图片目录下的所有图片文件名
    func getDeviceImageFileNames() -> [String] {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            DDLogInfo("无法获取Documents目录")
            return []
        }
        let deviceImgPath = documentsPath.appendingPathComponent("deviceImg")
        
        do {
            // 检查目录是否存在
            if !FileManager.default.fileExists(atPath: deviceImgPath.path) {
                DDLogInfo("deviceImg目录不存在")
                return []
            }
            
            // 获取目录中的所有文件
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: deviceImgPath.path)
            
            // 过滤出图片文件（根据常见图片扩展名）
            let imageFileNames = fileNames.filter { fileName in
                let fileExtension = (fileName as NSString).pathExtension.lowercased()
                return ["jpg", "jpeg", "png"].contains(fileExtension)
            }
            
            DDLogInfo("获取到设备图片文件: \(imageFileNames.count)张")
            return imageFileNames
        } catch {
            DDLogInfo("获取设备图片文件失败: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func getDeviceImageURLs() -> Observable<[URL]> {
        
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let fileNames = self.getDeviceImageFileNames()
            let urls = fileNames.compactMap { fileName in
                self.getDeviceImagePath(fileName: fileName)
            }
            DispatchQueue.main.async {
                self.phoneImgUrlFromDevice.accept(urls)
                observer.onNext(urls)
                observer.onCompleted()
            }
           
            
            return Disposables.create()
        }.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.instance)
    }
    
    /// 获取设备图片目录的总大小（单位：字节）
    func getDeviceImagesFolderSize() -> Int64 {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return 0
        }
        let deviceImgPath = documentsPath.appendingPathComponent("deviceImg")
        
        do {
            let resourceValues = try deviceImgPath.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
            return Int64(resourceValues.totalFileAllocatedSize ?? 0)
        } catch {
            DDLogInfo("获取设备图片目录大小失败: \(error.localizedDescription)")
            return 0
        }
    }
    
    /// 删除设备图片目录下的指定图片
    func deleteDeviceImage(fileName: String) -> Bool {
        guard let imageURL = getDeviceImagePath(fileName: fileName) else {
            DDLogInfo("删除本地图片失败 deleteDeviceImage: \(fileName)")
            return false
        }
        
        do {
            try FileManager.default.removeItem(at: imageURL)
            DDLogInfo("成功删除本地图片: \(fileName)")
            return true
        } catch {
            DDLogInfo("删除本地图片失败: \(error.localizedDescription)")
            return false
        }
    }
    
    func save2SystemAlbum(fileUrls:[URL]) {
        guard !fileUrls.isEmpty else { return }
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            if status == .authorized {
                var savedCount = 0
                let totalCount = fileUrls.count
                
                for url in fileUrls {
                    guard let imageData = try? Data(contentsOf: url),
                          let image = UIImage(data: imageData) else {
                        continue
                    }
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success {
                                savedCount += 1
                                DDLogInfo("保存图片成功: \(url.lastPathComponent)")
                                
                                // 显示保存进度
                                
                                // 如果全部保存完成
                                if savedCount == totalCount {
//                                    self.selfVc?.view.makeToast("全部保存完成")
                                    SJHud.showText(status: "has_save_count_photo")
                                }
                            } else {
                                DDLogInfo("保存图片失败: \(error?.localizedDescription ?? "")")
                                SJHud.showText(status: "save_fail")
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    // 显示权限未授权的提示
                    SJHud.showText(status: "当前无照片访问权限，需要允许访问「照片」中的「所有照片」。")
                    
                }
            }
        }
    }
}

