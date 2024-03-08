//
//  CustomDialController.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/29.
//

import Foundation
import UIKit
import AVFoundation
import Charts
//import HXPhotoPicker_Lite
import ZYImagePicker
import SnapKit
import SwifterSwift
//import HXPhotoPicker_Lite

///自定义表盘
@objcMembers
class CustomDialController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        
        return collectionView
    }()
    
    private var colors : [String] {
        return ["#000000", "#333333", "#F7B500", "#44D7B6", "#32C5FF"]
    }
    
    private var timeImages : [UIImage] {
        return [UIImage(named: "ic_dail_time_top_left") ?? UIImage(),
                UIImage(named: "ic_dail_time_bottom_left") ?? UIImage(),
                UIImage(named: "ic_dail_time_top_right") ?? UIImage(),
                UIImage(named: "ic_dail_time_bottom_right") ?? UIImage()]
    }
    
    lazy private var syncItem:UIButton = UIButton(title: "设为当前表盘".localized())
    lazy private var progreeeLb:UILabel = UILabel.init(text: "0%", textColor: UIColor(hex: 0x000000), font: UIFont.mediumFont(size: 16))
    lazy private var progressView:UIView = UIView.init()
    lazy private var imagePicker : ZYImagePicker = ZYImagePicker.init()
    lazy private var preview = TSDailCustomPreviewView()
    
    private var currentColorIndexPath : IndexPath = IndexPath()
    private var currentTimeIndexPath : IndexPath = IndexPath()
    typealias CommonBoolBlock = ((Bool) -> ())
    private let dialModel = TSWatchDailModel.init()
    var dailSyncSuccessBlcok:CommonBoolBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "自定义表盘".localized()
        
        congifureDefaultValue()
        
        updatePreView()
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(collectionView)
      self.view.backgroundColor = .white
        let blur = UIBlurEffect.init(style: .light)
        let effectview = UIVisualEffectView(effect: blur)
        view.addSubview(effectview)
        effectview.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(68 + bottomSafeHeight + 15)
            $0.bottom.equalToSuperview()
        }
        
        syncItem.addTarget(self, action: #selector(syncAction), for: .touchUpInside)
        syncItem.cornerRadius = 24
        syncItem.backgroundColor = UIColor.color23ED67
        syncItem.itemAlpha(false)
        syncItem.setTitleColor(UIColor.color000000, for: .normal)
        syncItem.isEnabled = false
        syncItem.titleLabel?.numberOfLines = 0
        
        view.addSubview(syncItem)
        
        syncItem.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(235)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-bottomSafeHeight - 20)
        }
        
        progressView.backgroundColor = UIColor.color23ED67.withAlphaComponent(0.7)
        syncItem.addSubview(progressView)
        progressView.cornerRadius = 48 / 2
        progressView.frame = CGRect.init(x: 0, y: 0, width: 0, height: 48)
        
        view.addSubview(progreeeLb)
        progreeeLb.textAlignment = .center
        progreeeLb.isHidden = true
        
        progreeeLb.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.bottom.equalTo(syncItem.snp.top).offset(-10)
            $0.trailing.equalToSuperview().offset(-12)
        }
        
        view.addSubview(preview)
        preview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            if let nav = self.navigationController {
                $0.top.equalToSuperview().offset(nav.navigationBar.height)
            } else {
                // 如果没有导航控制器，就使用安全区域的顶部
                $0.top.equalToSuperview().offset(80)
            }
            
            $0.height.equalTo(200)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.top.equalTo(preview.snp.bottom)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        preview.addGestureRecognizer(tapGesture)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(supplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withClass: TSDailCustomHeadView.self)
        collectionView.register(cellWithClass: TSDailCustomFontColorCell.self)
        collectionView.register(cellWithClass: TSDailCustomTimeStyleCell.self)
        collectionView.register(cellWithClass: TSDailCustomBgCell.self)
        
        collectionView.register(cellWithClass: TSDailCustomCollectionTimeStyleCell.self)
    }
    
    @objc func previewTapped() {
        print("View was tapped!")
        openPhotoSheetView()
    }
    
    
    @objc func syncAction() {
        startSendWatchFile()
    }
}

extension CustomDialController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch section {
        case 0:
            return 13.0
        case 1:
            return 13.0
        case 2:
            return 13.0
            
        default:
            return 13.0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
       
        case 0:
            return 1
        case 1:
            return 5
        
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        
        case 0:
            let cell = collectionView.dequeueReusableCell(withClass: TSDailCustomCollectionTimeStyleCell.self, for: indexPath)
            cell.setView(timeImages: self.timeImages) {[weak self] ip in
                guard let self = self else {return}
                self.currentTimeIndexPath = NSIndexPath(row: ip, section: 0) as IndexPath
                self.dialModel.textImage = self.timeImages[ip].withTintColor(self.dialModel.textColor ?? UIColor())
                self.dialModel.timeLocation = ip
                self.updatePreView()
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withClass: TSDailCustomFontColorCell.self, for: indexPath)
            cell.colorStr = colors[indexPath.row]
            return cell
        default : break
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
           
        case 0:
            return .init(width: screenWidth, height: 122)
        case 1:
            let width = (screenWidth - 13 * 5 - 10 * 2) / 6
            return CGSize.init(width: width, height: width)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withClass: TSDailCustomHeadView.self, for: indexPath)
            switch indexPath.section {
                //            case 0:
                //                headView.titleLB.text = "自定义背景"
            case 0:
                headView.titleLB.text = "时间样式".localized()
            case 1:
                headView.titleLB.text = "字体颜色".localized()
            default:
                headView.titleLB.text = ""
            }
            return headView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.init(width: screenWidth, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 2 {
            return UIEdgeInsets.init(top: 0, left: 10, bottom: 68 + bottomSafeHeight + 15, right: 10)
        }else {
            return UIEdgeInsets.init(top: 0, left: 10, bottom: 15, right: 10)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
            //        case 0:
            //            openPhotoSheetView()
        case 0:
            return;
            
        case 1: // 选择颜色
//            if  indexPath.row == colors.count - 1{
//                self.changeTextColor(indexPath)
//            }else{
                collectionView.deselectItem(at: currentColorIndexPath, animated: true)
                currentColorIndexPath = indexPath
                dialModel.textColor = UIColor(hexString: colors[indexPath.row])
                dialModel.textImage = timeImages[currentTimeIndexPath.row].withTintColor(dialModel.textColor  ?? UIColor())
                self.updatePreView()
//            }
            
        default: break
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch indexPath.section {
            //        case 0:
            //            openPhotoSheetView()
        case 0 ,1 :
//            if indexPath.row == colors.count - 1 {
//                self.changeTextColor(indexPath)
//            }
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        default: break
            
        }
    }
}
// MARK: 获取背景图
extension CustomDialController {
    
    private func changeTextColor(_ indexPath : IndexPath) {
        collectionView.deselectItem(at: currentColorIndexPath, animated: true)
        currentColorIndexPath = indexPath
        let _view = TSDialHsbColorView.init()
        _view.dailIcon.image = dialModel.bgImage
        _view.timeIcon.image = dialModel.textImage
        _view.fontColor = dialModel.textColor
        _view.timeChangeBlock = { [weak self] reslutColor in
            guard let self = self else { return }
            if let _reslutColor = reslutColor{
                self.dialModel.textColor = _reslutColor
                self.dialModel.textImage = self.timeImages[self.currentTimeIndexPath.row].withTintColor(self.dialModel.textColor ?? UIColor())
            }
            self.updatePreView()
        }
        self.preview.isHidden = true
        
        _view.show()
    }
    
    private func openPhotoSheetView() {
        let items = ["拍照".localized() , "相册".localized() , "视频".localized()]
        
        let sheetView = TSAlertSheetListView.init(items: items) {[weak self] idx in
            guard let idx = idx else {return}
            if items[idx] == "拍照".localized() {
                self?.isAuthorizationCamera(completion: { isOpen in
                    if isOpen {
                        self?.openCamera()
                    }
                })
            }else if items[idx] == "相册".localized() {
                self?.isAuthorizationPhoto(completion: { isOpen in
                    if isOpen {
                        self?.openPhotoLibrary()
                    }
                })
            }else if items[idx] == "视频".localized() {
                self?.isAuthorizationPhoto(completion: { isOpen in
                    if isOpen {
                        self?.openVideoLibrary()
                    }
                })
            }
        }
        sheetView.show()
    }
    
    private func openCamera() {
        
        let imageSize = TSDeviceDialTools.shared.getDialSize()
        
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let weakSelf = self else {
                return
            }
            DispatchQueue.main.async {
                if granted {
                    weakSelf.imagePicker.cameraPhoto(with: weakSelf, cropSize: imageSize, imageScale: 1, isCircular: false, formDataBlock: { image, formData in
                        let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
                        if let temp = image?.cgImage , let cgimage = temp.cropping(to: rect) {
                            self?.dialModel.bgImage = UIImage.init(cgImage: cgimage).cornerWithRadius(TSDeviceDialTools.shared.getcornerRadii())
                            self?.updateSyncItem(isSyne: true)
                            self?.updatePreView()
                        }
                        //
                    })
                }else{
                    
                }
            }
        }
    }

    
    private func openPhotoLibrary() {

        let imageSize = TSDeviceDialTools.shared.getDialSize()
        //        let dialScreenType = getDeviceType().getDialAppearanceType
        let isCircle = false

        imagePicker.libraryPhoto(with: self, cropSize: imageSize, imageScale: 1, isCircular: isCircle, formDataBlock: {[weak self] image, formData in
            
            let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            if let temp = image?.cgImage , let cgimage = temp.cropping(to: rect) {
                self?.dialModel.bgImage = UIImage.init(cgImage: cgimage).cornerWithRadius(TSDeviceDialTools.shared.getcornerRadii())
                self?.updateSyncItem(isSyne: true)
                self?.updatePreView()
            }
        })
    }
    private func openVideoLibrary() {
  
        imagePicker.libraryMoive(with: self, maximumDuration: 5) {[weak self] _, data in
            guard let videoURL = data?.fileUrl else {return}
            let outputFileType = AVFileType.mp4
            
            self?.compressAndResizeVideoWithThumbnail(videoURL: videoURL) { result in
                switch result {
                case .success(let (videoPath, thumbnailImage)):
                    print("Video conversion successful, new video path: \(videoPath)")
                    self?.dialModel.isVideo = true
                    self?.dialModel.filePath = videoPath.path
                    self?.dialModel.bgImage = thumbnailImage
                    DispatchQueue.main.async {
                        self?.updateSyncItem(isSyne: true)
                        self?.updatePreView()
                    }
                    
                case .failure(let error):
                    print("fail: \(error)")
                }
            }
        }
    }
    
    func compressAndResizeVideoWithThumbnail(videoURL: URL, outputFileType: AVFileType = .mp4, completion: @escaping (Result<(videoPath: URL, thumbnailImage: UIImage?), Error>) -> Void) {
        let targetSize = CGSize(width: 320, height: 386) // 目标尺寸
        let asset = AVAsset(url: videoURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "ExportSessionCreationFailed", code: 0, userInfo: nil)))
            return
        }
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            completion(.failure(NSError(domain: "VideoTrackError", code: 0, userInfo: nil)))
            return
        }
        let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputPath = documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mp4")
        exportSession.outputURL = outputPath
        exportSession.outputFileType = outputFileType
        
        // 设置视频帧的压缩和尺寸调整
        let videoComposition = AVMutableVideoComposition(propertiesOf: asset)
        videoComposition.renderSize = targetSize
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30) // 设置帧率
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        // 计算缩放和位移，使视频填满目标尺寸
        let originalSize = videoTrack.naturalSize
        var finalTransform = videoTrack.preferredTransform
        // 根据视频的方向调整 originalSize
        let adjustedSize = assetInfo.isPortrait ? CGSize(width: originalSize.height, height: originalSize.width) : originalSize
        let scaleX = targetSize.width / adjustedSize.width
        let scaleY = targetSize.height / adjustedSize.height
        let scale = max(scaleX, scaleY) // 选择较大的缩放比例以填满目标尺寸
        let scaledWidth = adjustedSize.width * scale
        let scaledHeight = adjustedSize.height * scale
        let translateX = (targetSize.width - scaledWidth) / 2 // 居中调整
        let translateY = (targetSize.height - scaledHeight) / 2 // 居中调整
        finalTransform = finalTransform.translatedBy(x: translateX / scale, y: translateY / scale) // 应用位移
        finalTransform = finalTransform.scaledBy(x: scale, y: scale) // 应用缩放
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(finalTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        exportSession.videoComposition = videoComposition
        
        // 开始导出视频
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                // 视频转换成功后，生成封面图
//                let fileURL = URL(fileURLWithPath: outputPath)
                let outPutAsset = AVURLAsset(url: outputPath)
                let assetImgGenerate = AVAssetImageGenerator(asset: outPutAsset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
                
                do {
                    let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: img)
                    completion(.success((videoPath: outputPath, thumbnailImage: thumbnail)))
                } catch {
                    // 即使封面图生成失败，也返回视频路径
                    completion(.success((videoPath: outputPath, thumbnailImage: nil)))
                }
            case .failed, .cancelled:
                if let error = exportSession.error {
                    completion(.failure(error))
                }
            default:
                break
            }
        }
    }


    // 根据视频轨道的 preferredTransform 来判断视频的方向
    func orientationFromTransform(transform: CGAffineTransform) -> VideoOrientation {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d

        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
            assetOrientation = .up
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            assetOrientation = .down
        }
        
        return VideoOrientation(orientation: assetOrientation, isPortrait: isPortrait)
    }
}
// 定义一个结构体来存储视频的方向信息
struct VideoOrientation {
    var orientation: UIImage.Orientation
    var isPortrait: Bool
}
// 刷新表盘预览图
extension CustomDialController {
    
    private func creatimageWithColor(color:UIColor)->UIImage{
        let rect = CGRectMake(0.0,0.0,240,280)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func updatePreView() {
        
        dialModel.textImage = timeImages[currentTimeIndexPath.row].withTintColor(dialModel.textColor ?? UIColor())
        preview.dailIcon.image = dialModel.bgImage
        preview.timeIcon.image = dialModel.textImage
        preview.loadVideoIfNeed(model: dialModel)
        self.preview.isHidden = false
    }
}

// MARK: 同步创作表盘
extension CustomDialController {

    
    private func updateSyncItem(isSyne : Bool) {
        syncItem.itemAlpha(isSyne)
        syncItem.isEnabled = isSyne
    }
    
    // 重置更新状态
    private func resetItem() {
        syncItem.setTitle("设为当前表盘".localized(), for: .normal)
        syncItem.itemAlpha(true)
        
        progressView.isHidden = true
        progressView.frame = CGRect.init(x: 0, y: 0, width: 0, height: 48)
        
        progreeeLb.text = "0%"
        progreeeLb.isHidden = true
    }
    
    // 开始表盘传输
    private func startSendWatchFile() {
        
        self.updateProgress(progress: 0)
        
        dialModel.dailId = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
   
        DispatchQueue.main.async {
      
            let fileHandler = WatchManager.sharedInstance().currentValue.apps.fileApp
            let model = self.dialModel.toWmModel()
            fileHandler.startTransferCustomDial(model).subscribeNext { progress in
                DispatchQueue.main.async {
                    guard let progress = progress, progress.isFail == false else {
                        self.fileTransComplete(0, .Failed, -1)
                        NSLog("apps is nil  \(String(describing: progress?.error?.localizedDescription) )")
                        UIApplication.shared.isIdleTimerDisabled = false
                        return
                    }
                    self.fileTransComplete(Int(progress.progress), .InTransit, nil)
                }
            } error: { error in
                DispatchQueue.main.async {
                    self.fileTransComplete(0, .Failed, -1)
                    NSLog("completion?(0, .Failed, \(String(describing: error?.localizedDescription))")
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            } completed: {
                DispatchQueue.main.async {
                    NSLog("completion?(100, .Succeed, nil)")
                    self.fileTransComplete(100, .Succeed, nil)
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            }
        }
    }
    
    func fileTransComplete(_ progress: Int, _ status: TSProgressState, _ errorCode:Int?){
        switch status {
        case .InTransit:
            self.updateProgress(progress: progress)
           
        case .Succeed:
            self.updateProgress(progress: progress)
            self.deviceUpdateSuccess()
            break
        case .Failed:
            //
            if self.progressView.isHidden == true {
                return
            }
            self.devoceUpdateFail()
           
            break
        default : break
        }
    }
    
    // 更新进度
    private func updateProgress(progress : Int) {
        syncItem.setTitle("", for: .normal)
        syncItem.itemAlpha(false)
        
        progressView.isHidden = false
        progressView.width =  CGFloat(235 * (CGFloat(progress) / 100))
        
        progreeeLb.text = "\(progress)%"
        progreeeLb.isHidden = false
    }
    
    private func devoceUpdateFail() {
        
    }
    
    private func deviceUpdateSuccess() {
      
        self.dailSyncSuccessBlcok?(true)
 
        congifureDefaultValue()
        self.resetItem()
        syncItem.itemAlpha(false)
        syncItem.isEnabled = false
    }
    
    private func congifureDefaultValue() {

        currentColorIndexPath = IndexPath.init(item: 0, section: 2)
        currentTimeIndexPath = IndexPath.init(item: 0, section: 1)
        
        dialModel.textColor = UIColor(hexString: colors[currentColorIndexPath.row])
        dialModel.textImage = timeImages[currentTimeIndexPath.row].withTintColor(dialModel.textColor ?? UIColor())
        dialModel.dailRule = TSDeviceDialTools.shared.getDialRule()
        
        dialModel.filePath =  Bundle.main.path(forResource: TSDeviceDialTools.shared.getDialBinPath(idx: currentTimeIndexPath.row), ofType: "bin") ?? ""
        dialModel.dailId = TSDeviceDialTools.shared.getDialId(idx: currentTimeIndexPath.row)
        
        self.dialModel.bgImage = nil
        self.updateSyncItem(isSyne: false)

        self.updatePreView()
        self.collectionView.reloadData()

    }

}


extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        if size.width == targetSize.width && size.height == targetSize.height {
            return self
        }
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let newSize = CGSize(width: size.width * widthRatio, height: size.height * heightRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}


/// 传输状态
enum TSProgressState: Error {
    /// 传输失败
    case Failed
    /// 传输成功
    case Succeed
    /// 传输中
    case InTransit
    /// 开始传输
    case Start
}
