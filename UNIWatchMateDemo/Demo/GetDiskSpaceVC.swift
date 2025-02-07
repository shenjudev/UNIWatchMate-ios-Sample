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

class GetDiskSpaceVC: UIViewController {
  
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "internaldrive.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "存储空间"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .systemGray5
        progress.progressTintColor = .systemBlue
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.transform = CGAffineTransform(scaleX: 1, y: 2)
        return progress
    }()
    
    private lazy var usedSpaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var totalSpaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var disposable: RACDisposable?
    var isOnResume = false
    private lazy var simpleImg = UIImageView()
        
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
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            //            self.addNotice()
        }
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "存储空间"
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(progressView)
        containerView.addSubview(usedSpaceLabel)
        containerView.addSubview(totalSpaceLabel)
        containerView.addSubview(detailLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(320)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        usedSpaceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        totalSpaceLabel.snp.makeConstraints { make in
            make.top.equalTo(usedSpaceLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(totalSpaceLabel.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(8)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(25)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
        
        SVProgressHUD.show()
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.deviceStoreageInfo().subscribeNext {[weak self] deviceStoreageInfo in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            
            let remainSize = self.stringToMegabytesString(deviceStoreageInfo?.remain as String?)
            let totalSize = self.stringToMegabytesString(deviceStoreageInfo?.total as String?)
            
            // 计算已使用空间和百分比
            if let remain = deviceStoreageInfo?.remain as? String, 
               let total = deviceStoreageInfo?.total as? String,
               let remainBytes = Double(remain), 
               let totalBytes = Double(total) {
                let usedBytes = totalBytes - remainBytes
                let percentage = usedBytes / totalBytes
                
                self.progressView.progress = Float(percentage)
                self.usedSpaceLabel.text = self.stringToMegabytesString(String(Int(usedBytes)))
                self.totalSpaceLabel.text = "总容量：\(totalSize)"
                self.detailLabel.text = "剩余可用：\(remainSize)"
            }
            
        } error: { error in
            SVProgressHUD.dismiss()
            print(error as Any)
        }
    }
    
    func stringToMegabytesString(_ input: String?, _ total: Bool = false) -> String {
        // 1. 安全地解包可选的 String
        guard let string = input, let bytes = Int(string) else {
            print("输入的字符串为空或无法将字符串转换为字节数")
            return ""
        }

        // 2. 计算字节数
        let bytesInMB = 1024
        let bytesInGB = bytesInMB * 1024

        // 3. 计算 GB 和 MB
        let gb = Double(bytes) / Double(bytesInGB) // 计算GB数
        let mb = Double(bytes) / Double(bytesInMB) // 计算MB数
        
        // 4. 处理大于1GB的情况
        if gb >= 1 {
            // 当total为true时，向上取整GB
            if gb.truncatingRemainder(dividingBy: 1) == 0 {
                        return String(format: "%.0fGB", gb) // 如果是整数GB，不显示小数位
                    } else {
                        return String(format: "%.2fGB", gb) // 否则保留两位小数
                    }
        } else {
            // 小于1GB，显示MB
            return String(format: "%.0fMB", mb) // 取整MB
        }
    }

    
    func bytesToGBMBString(_ bytes: Int) -> String {
        let bytesInMB = 1024 * 1024
        let bytesInGB = bytesInMB * 1024123

        let gb = bytes / bytesInGB
        let mb = Double(bytes % bytesInGB) / Double(bytesInMB)
        
        return "\(bytes) bytes is approximately \(gb) GB and \(String(format: "%.2f", mb)) MB."
    }
}

