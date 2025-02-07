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

class RecordVideoVC: UIViewController {
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
        imageView.image = UIImage(systemName: "video.circle.fill")
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
    
    private lazy var recordingDot: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 4
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        return view
    }()

    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.text = "录像".localized()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
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
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "点击按钮开始/停止录像".localized()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var recordingTimer: Timer?
    private var recordingSeconds: Int = 0
    private var dotAnimationTimer: Timer?
    
    var disposable: RACDisposable?
    var isOnResume = false
    var recording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addNotice()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecordingTimer()
        stopDotAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        isOnResume = true
        checkRecordingState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        disposable?.dispose()
    }
    
    func addNotice() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRecordNoti(_:)), name: Notification.Name(NOTI_watchOpenOrCloseRecordVideo), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "录像".localized()
        
        view.addSubview(containerView)
        containerView.addSubview(recordIconImageView)
        containerView.addSubview(recordingIndicator)
        containerView.addSubview(recordingDot)
        containerView.addSubview(recordLabel)
        containerView.addSubview(timeLabel)
        view.addSubview(descriptionLabel)
        
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
        
        recordingDot.snp.makeConstraints { make in
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRecordTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
    
    private func checkRecordingState() {
        SVProgressHUD.show()
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.deviceRecordVideoState().subscribeNext {[weak self] result in
            SVProgressHUD.dismiss()
            DDLogInfo("deviceVideoState result = \(result)")
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
        recordLabel.text = isRecording ? "录像中...".localized() : "录像".localized()
        
        UIView.animate(withDuration: 0.3) {
            self.recordingIndicator.alpha = isRecording ? 1 : 0
            self.recordingDot.alpha = isRecording ? 1 : 0
            self.timeLabel.alpha = isRecording ? 1 : 0
            self.recordIconImageView.tintColor = isRecording ? .systemRed : .systemBlue
        }
        
        if isRecording {
            startRecordingTimer()
            startDotAnimation()
        } else {
            stopRecordingTimer()
            stopDotAnimation()
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
        timeLabel.text = "00:00"
    }
    
    private func updateTimeLabel() {
        let minutes = recordingSeconds / 60
        let seconds = recordingSeconds % 60
        timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startDotAnimation() {
        // 创建闪烁动画
        dotAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            UIView.animate(withDuration: 0.5) {
                self?.recordingDot.alpha = 0
            } completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self?.recordingDot.alpha = 1
                }
            }
        }
    }
    
    private func stopDotAnimation() {
        dotAnimationTimer?.invalidate()
        dotAnimationTimer = nil
        recordingDot.alpha = 0
    }
    
    @objc func receiveRecordNoti(_ noticeInfo: NSNotification?) {
        if let dic = noticeInfo?.userInfo {
            if let result = dic["result"] as? Int {
                if result == 1 {
                    updateRecordingState(true)
                } else if result == 0 {
                    updateRecordingState(false)
                } else {
                    SVProgressHUD.showError(withStatus: "录像失败，设备忙".localized())
                }
            }
        }
    }
    
    @objc func handleRecordTap(_ sender: UITapGestureRecognizer) {
        // 添加点击反馈动画
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
            }
        }
        
        SVProgressHUD.show(withStatus: recording ? "停止录像中...".localized() : "开始录像...".localized())
        WatchManager.sharedInstance().currentValue.apps.watchGlassesVideoApp.startRecordVideoSet(!recording).subscribeNext {[weak self] result in
            SVProgressHUD.dismiss()
            DDLogInfo("startVideoSet result = \(result)")
        } error: { error in
            print(error as Any)
            SVProgressHUD.showError(withStatus: "操作失败".localized())
        } completed: {
        }
    }
}

