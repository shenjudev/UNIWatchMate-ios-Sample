//
//  SJDevCameraPreviewVC.swift
//  SparkPro
//
//  Created by t_t on 2024/1/2.
//  Copyright © 2024 SparkPro. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa
import SVProgressHUD

class WatchVideoPreviewVC: UIViewController {

    var disposable: RACDisposable?
    var isOnResume = false
    private lazy var previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.15
        view.clipsToBounds = false
        return view
    }()

    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "等待预览...".localized()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.alpha = 0.8
        return label
    }()
    
    let serialQueue = DispatchQueue(label: "com.h264.serialQueue")
    var needFirstFrame = true
    
    // 新增视频显示层
    //     let videoLayer = AVSampleBufferDisplayLayer()
    var videoDecoder: VideoDecoder?
    
    func initVideoDecoder() {
        videoDecoder = VideoDecoder(sampleBufferCallback: {[weak self] imageBuffer in
            guard let self = self else { return }
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                return
            }
            let image = UIImage(cgImage: cgImage)
            // 在主线程更新UI
            DispatchQueue.main.async {
                if self.needFirstFrame {
                    self.needFirstFrame = false
                    self.statusLabel.text = ""  // 收到第一帧时清除状态文本
                }
                self.previewImageView.image = image
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        isOnResume = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        disposable?.dispose()
        isOnResume = false
        previewImageView.image = nil
        statusLabel.text = "预览已停止".localized()
        
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.startPreviewSet(false).subscribeNext { rs in
            print("startPreviewSet(false) rs=\(String(describing: rs))")
        } error: { error in
            print(error as Any)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            //            self.addNotice()
        }
        setupUI()
        initVideoDecoder()

    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "设备视频预览".localized()
        
        view.addSubview(previewContainer)
        previewContainer.addSubview(previewImageView)
        previewContainer.addSubview(statusLabel)
        
        previewContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(210)
        }
        
        previewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.startPreviewSet(true).subscribeNext {[weak self] success in
            guard let self = self else { return }
            if success == false {
                SVProgressHUD.showError(withStatus: "打开预览失败".localized())
                self.statusLabel.text = "预览失败".localized()
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                self.statusLabel.text = "预览中...".localized()
                disposable = WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.monitorVideo().subscribeNext { [weak self] rs in
                    guard let self = self else { return }
                    serialQueue.async {[weak self] in
                        self?.videoDecoder?.handleOriginH264Data(rs as! Data)
                    }
                } error: { error in
                    print("error \(error)")
                    self.statusLabel.text = "预览错误".localized()
                }
            }
        } error: { error in
            SVProgressHUD.showError(withStatus: error?.localizedDescription ?? "")
            self.statusLabel.text = "预览错误".localized()
        }
    }
    
    
    func saveImageToGlassesDirectory(imageData: Data) -> URL? {
        // 获取 PNG 图片数据
        
        // 获取当前时间戳作为图片名称
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        let timestamp = dateFormatter.string(from: Date())
        let imageName = "\(timestamp)"
        
        let saveImgdateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHH"
        let saveImgtimestamp = dateFormatter.string(from: Date())
        let fileManager = FileManager.default
        do {
            // 获取应用的文档目录
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            // 定义 "glasses" 子目录路径
            let glassesDirectory = documentDirectory.appendingPathComponent("DeviceVideoPreview\(saveImgtimestamp)")
            
            // 创建 "glasses" 目录（如果不存在）
            if !fileManager.fileExists(atPath: glassesDirectory.path) {
                try fileManager.createDirectory(at: glassesDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            // 定义保存图片的文件路径
            let filePath = glassesDirectory.appendingPathComponent("\(imageName).jpg")
            
            // 将图片数据写入指定路径
            try imageData.write(to: filePath)
            
            print("Image saved to \(filePath)")
            return filePath
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }
    
}

extension UIViewController {
    func customPrint(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let dateString = dateFormatter.string(from: Date())
        
        print("\(dateString) \(message)")
    }
}
