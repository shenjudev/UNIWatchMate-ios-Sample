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

class MediaCountVC: UIViewController {
  
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
        imageView.image = UIImage(systemName: "photo.stack.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "媒体统计"
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private lazy var musicView = createStatView(icon: "music.note", title: "音乐")
    private lazy var videoView = createStatView(icon: "video", title: "视频")
    private lazy var photoView = createStatView(icon: "photo", title: "照片")
    private lazy var recordView = createStatView(icon: "waveform", title: "录音")
    
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
    
    private func createStatView(icon: String, title: String) -> UIView {
        let container = UIView()
        container.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .systemBlue
        
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        
        container.addSubview(iconView)
        container.addSubview(label)
        
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        
        return container
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "媒体数量"
        
        view.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(musicView)
        statsStackView.addArrangedSubview(videoView)
        statsStackView.addArrangedSubview(photoView)
        statsStackView.addArrangedSubview(recordView)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(400)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
        
        SVProgressHUD.show()
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.deviceMediaCount().subscribeNext {[weak self] mediaCount in
            SVProgressHUD.dismiss()
            guard let self = self else { return }
            
            if let musicLabel = (self.musicView.subviews.last as? UILabel) {
                musicLabel.text = "音乐：\(mediaCount?.music_num ?? 0)"
            }
            if let videoLabel = (self.videoView.subviews.last as? UILabel) {
                videoLabel.text = "视频：\(mediaCount?.video_num ?? 0)"
            }
            if let photoLabel = (self.photoView.subviews.last as? UILabel) {
                photoLabel.text = "照片：\(mediaCount?.photo_num ?? 0)"
            }
            if let recordLabel = (self.recordView.subviews.last as? UILabel) {
                recordLabel.text = "录音：\(mediaCount?.record_num ?? 0)"
            }
        } error: { error in
            print(error as Any)
            SVProgressHUD.dismiss()
        } completed: {
        }
    }
    
}

