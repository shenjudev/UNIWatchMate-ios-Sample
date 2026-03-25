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
    /// 无存储设备：当前一次录音会话内累积的 PCM
    private var sessionPCMBuffer = Data()
    private var isAcceptingPCMFromDevice = false
    /// 仅保留最近一次完整录音结束后的 PCM（覆盖上一次）
    private var latestSavedPCMData: Data?
    private var finalizePCMWorkItem: DispatchWorkItem?
    private var audioPlayer: AVAudioPlayer?
    
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
    
    private lazy var playSavedRecordingButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("保存的录音文件".localized(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.addTarget(self, action: #selector(playSavedRecordingTapped), for: .touchUpInside)
        return btn
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
        audioPlayer?.stop()
        audioPlayer = nil
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
        view.addSubview(playSavedRecordingButton)
        
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
        
        playSavedRecordingButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
        }
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRecordTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // 查询当前录音状态
        checkRecordingState()
        updatePlaySavedButtonAppearance()
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
        //设置无存储设备 录音数据的delegate
        WatchManager.sharedInstance().current.subscribeNext {[weak self] peripheral in
            peripheral?.otherDataDelegate = self

        }
    }
    
    private func updateRecordingState(_ isRecording: Bool) {
        let wasRecording = recording
        recording = isRecording
        recordLabel.text = isRecording ? "录音中...".localized() : "录音".localized()
        
        if isRecording {
            finalizePCMWorkItem?.cancel()
            sessionPCMBuffer.removeAll(keepingCapacity: true)
            isAcceptingPCMFromDevice = true
        } else if wasRecording {
            scheduleFinalizeLatestPCM()
        }
        
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
    
    private func scheduleFinalizeLatestPCM() {
        finalizePCMWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.isAcceptingPCMFromDevice = false
            if !self.sessionPCMBuffer.isEmpty {
                self.latestSavedPCMData = self.sessionPCMBuffer
            }
            self.updatePlaySavedButtonAppearance()
        }
        finalizePCMWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }
    
    private func updatePlaySavedButtonAppearance() {
        let hasData = !(latestSavedPCMData?.isEmpty ?? true)
        playSavedRecordingButton.isEnabled = hasData
        playSavedRecordingButton.alpha = hasData ? 1.0 : 0.45
    }
    
    @objc private func playSavedRecordingTapped() {
        guard let pcmData = latestSavedPCMData, !pcmData.isEmpty else {
            SVProgressHUD.showError(withStatus: "暂无音频数据".localized())
            return
        }
        guard let wavData = convertPCMToWAV(pcmData: pcmData) else {
            SVProgressHUD.showError(withStatus: "数据转换失败".localized())
            return
        }
        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(data: wavData)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            SVProgressHUD.showSuccess(withStatus: "正在播放...".localized())
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                SVProgressHUD.dismiss()
            }
        } catch {
            DDLogError("RecordVC play saved recording error: \(error)")
            SVProgressHUD.showError(withStatus: "音频播放失败".localized())
        }
    }
    
    /// 与设备侧 PCM 约定一致：16kHz、单声道、16bit（与 NewAiChatVC 一致）
    private func convertPCMToWAV(pcmData: Data) -> Data? {
        let sampleRate: UInt32 = 16000
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * bitsPerSample / 8
        let pcmDataSize = UInt32(pcmData.count)
        let headerSize: UInt32 = 44
        let totalSize = headerSize + pcmDataSize - 8
        var headerData = Data()
        headerData.append("RIFF".data(using: .utf8)!)
        headerData.append(withUnsafeBytes(of: totalSize.littleEndian) { Data($0) })
        headerData.append("WAVE".data(using: .utf8)!)
        headerData.append("fmt ".data(using: .utf8)!)
        let fmtChunkSize: UInt32 = 16
        headerData.append(withUnsafeBytes(of: fmtChunkSize.littleEndian) { Data($0) })
        let audioFormat: UInt16 = 1
        headerData.append(withUnsafeBytes(of: audioFormat.littleEndian) { Data($0) })
        headerData.append(withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        headerData.append(withUnsafeBytes(of: sampleRate.littleEndian) { Data($0) })
        headerData.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        headerData.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        headerData.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        headerData.append("data".data(using: .utf8)!)
        headerData.append(withUnsafeBytes(of: pcmDataSize.littleEndian) { Data($0) })
        var wavData = Data()
        wavData.append(headerData)
        wavData.append(pcmData)
        return wavData
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

//无存储设备
extension RecordVC: WMOtherDataDelegate {
    func device4A02Push(_ data: Data) {
        
    }
    
    func deviceAudioRecord(_ data: Data) {
        // 无存储设备 开始录音后，设备会一直发送语言数据给APP
        // 收到无存储设备的 pcm录音数据
        DDLogInfo("收到无存储设备的 PCM录音数据，数据大小: \(data.count) bytes")
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isAcceptingPCMFromDevice, !data.isEmpty else { return }
            self.sessionPCMBuffer.append(data)
        }
    }
    
}

extension RecordVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
    }
}

