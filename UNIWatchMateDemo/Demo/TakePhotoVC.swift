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

class TakePhotoVC: UIViewController {
    // UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var cameraIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()

    private lazy var cameraLabel: UILabel = {
        let label = UILabel()
        label.text = "拍照".localized()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "点击按钮开始拍照".localized()
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
      
        setupUI()
        self.addNotice()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "拍照".localized()
        
        // Add subviews
        view.addSubview(containerView)
        containerView.addSubview(cameraIconImageView)
        containerView.addSubview(cameraLabel)
        view.addSubview(descriptionLabel)
        
        // Setup constraints
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(160)
        }
        
        cameraIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }
        
        cameraLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cameraIconImageView.snp.bottom).offset(12)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCameraTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    func addNotice() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTakePhoto(_ :)), name: Notification.Name(NOTI_watchTakePhoto), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func receiveTakePhoto(_ noticeInfo:NSNotification?) {
        if let dic = noticeInfo?.userInfo {
            if let result = dic["result"] as? Int {
                if result != 1 {
                    SVProgressHUD.showError(withStatus: "\("拍照失败".localized()) result = \(String(describing: result))")
                }else {
                    SVProgressHUD.showSuccess(withStatus: "拍照成功".localized())
                }
            }
        }
    }
    
    @objc func handleCameraTap(_ sender: UITapGestureRecognizer) {
        // Add animation feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        
        SVProgressHUD.show()
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.deviceTakePhoto().subscribeNext {[weak self] result in
            SVProgressHUD.dismiss()
            DDLogInfo("deviceTakePhoto result = \(String(describing: result))")
            guard let self = self else { return }
            if result?.boolValue ?? false  {
                DDLogInfo("deviceTakePhoto 拍照命令发送成功")
            }else {
                SVProgressHUD.showError(withStatus: "\("拍照失败".localized()) result = \(String(describing: result))")
            }
        } error: { error in
            print(error as Any)
            SVProgressHUD.dismiss()
        } completed: {
        }
    }
}

