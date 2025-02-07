//
//  SJDevCameraPreviewVC.swift
//  SparkPro
//
//  Created by t_t on 2024/1/2.
//

import UIKit
import AVFoundation
import Photos
import RxSwift
import RxCocoa
import SVProgressHUD

class RecordVC: UIViewController {
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
    
    private lazy var recordIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private lazy var recordingIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 4
        view.alpha = 0
        return view
    }()

    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.text = "录音".localized()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "点击按钮开始/停止录音".localized()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private var recordingTimer: Timer?
    private var recordingSeconds: Int = 0
    
    var disposable: RACDisposable?
    var isOnResume = false
    var recording = false
    private lazy var simpleImg = UIImageView()
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecordingTimer()
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
        addNotice()
    }
    func addNotice() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRecordNoti(_ :)), name: Notification.Name(NOTI_watchOpenOrCloseRecord), object: nil)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "录音".localized()
        
        // Add subviews
        view.addSubview(containerView)
        containerView.addSubview(recordIconImageView)
        containerView.addSubview(recordingIndicator)
        containerView.addSubview(recordLabel)
        containerView.addSubview(timeLabel)
        view.addSubview(descriptionLabel)
        
        // Setup constraints
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(180)
        }
        
        recordIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-25)
            make.width.height.equalTo(70)
        }
        
        recordingIndicator.snp.makeConstraints { make in
            make.right.equalTo(recordIconImageView.snp.right).offset(-5)
            make.top.equalTo(recordIconImageView.snp.top).offset(5)
            make.width.height.equalTo(8)
        }
        
        recordLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordIconImageView.snp.bottom).offset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordLabel.snp.bottom).offset(8)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRecordTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // 查询当前录音状态
        checkRecordingState()
    }
    
    private func checkRecordingState() {
        SVProgressHUD.show()
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.deviceRecordState().subscribeNext {[weak self] result in
            SVProgressHUD.dismiss()
            DDLogInfo("deviceRecordState result = \(result)")
            guard let self = self else { return }
            self.updateRecordingState(result == 1)
        } error: { error in
            print(error as Any)
            SVProgressHUD.dismiss()
        } completed: {
        }
    }
    
    private func updateRecordingState(_ isRecording: Bool) {
        recording = isRecording
        recordLabel.text = isRecording ? "录音中...".localized() : "录音".localized()
        
        UIView.animate(withDuration: 0.3) {
            self.recordingIndicator.alpha = isRecording ? 1 : 0
            self.timeLabel.alpha = isRecording ? 1 : 0
            self.recordIconImageView.tintColor = isRecording ? .systemRed : .systemBlue
        }
        
        if isRecording {
            startRecordingTimer()
        } else {
            stopRecordingTimer()
        }
    }
    
    private func startRecordingTimer() {
        recordingSeconds = 0
        updateTimeLabel()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingSeconds += 1
            self?.updateTimeLabel()
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        recordingSeconds = 0
    }
    
    private func updateTimeLabel() {
        let minutes = recordingSeconds / 60
        let seconds = recordingSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc func receiveRecordNoti(_ noticeInfo:NSNotification?) {
        if let dic = noticeInfo?.userInfo {
            if let result = dic["result"] as? Int {
                if result == 1 {
                    updateRecordingState(true)
                } else if result == 0 {
                    updateRecordingState(false)
                } else {
                    SVProgressHUD.showError(withStatus: "录音失败，设备忙".localized())
                }
            }
        }
    }
    
    @objc func handleRecordTap(_ sender: UITapGestureRecognizer) {
        // Add animation feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        
        SVProgressHUD.show(withStatus: recording ? "停止录音中...".localized() : "开始录音...".localized())
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.startRecordSet(!recording).subscribeNext {[weak self] result in
            SVProgressHUD.dismiss()
            DDLogInfo("startRecordSet result = \(result)")
        } error: { error in
            print(error as Any)
            SVProgressHUD.showError(withStatus: "操作失败".localized())
        } completed: {
        }
    }
}

