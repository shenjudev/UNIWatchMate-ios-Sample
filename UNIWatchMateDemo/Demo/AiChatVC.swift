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

class AiChatVC: UIViewController {

    var disposable: RACDisposable?
    var isOnResume = false
    private var debugPCMData: Data?
    private var audioPlayer: AVAudioPlayer?

    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.15
        return view
    }()
    
    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 18
        return imageView
    }()
    
    private lazy var aiButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("播放音频".localized(), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
        button.addTarget(self, action: #selector(aiButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()
    
    private lazy var dataInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.alpha = 0.8
        return label
    }()

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
        
        WatchManager.sharedInstance().current.subscribeNext { wMPeripheral in
            wMPeripheral?.aiAssistantDelegate = self
        }

    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "AI对话".localized()
        
        view.addSubview(containerView)
        containerView.addSubview(previewImageView)
        view.addSubview(aiButton)
        view.addSubview(statusLabel)
        view.addSubview(dataInfoLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(210)
        }
        
        previewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        aiButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(containerView.snp.bottom).offset(20)
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(aiButton.snp.bottom).offset(8)
        }
        
        dataInfoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
        }
    }
    
    @objc private func aiButtonTapped() {
        guard let pcmData = debugPCMData, !pcmData.isEmpty else {
            showToast("暂无音频数据".localized())
            return
        }
        
        // 添加点击反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.aiButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.aiButton.transform = .identity
            }
        }
        
        // 转换并播放音频
        if let wavData = convertPCMToWAV(pcmData: pcmData) {
            do {
                audioPlayer = try AVAudioPlayer(data: wavData)
                audioPlayer?.delegate = self
                audioPlayer?.play()
                
                // 显示正在播放状态
                showPlayingStatus()
            } catch {
                print("Error playing audio: \(error)")
                showToast("音频播放失败".localized())
            }
        }
    }
    
    private func showPlayingStatus() {
        statusLabel.text = "正在播放...".localized()
        UIView.animate(withDuration: 0.3) {
            self.statusLabel.alpha = 1
        }
    }
    
    private func hidePlayingStatus() {
        UIView.animate(withDuration: 0.3) {
            self.statusLabel.alpha = 0
        }
    }
    
private func showToast(_ message: String) {
        statusLabel.text = message
        UIView.animate(withDuration: 0.3, animations: {
            self.statusLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                UIView.animate(withDuration: 0.3) {
                    self.statusLabel.alpha = 0
                }
            }
        }
    }
    
    private func updateDataInfo() {
        guard let pcmData = debugPCMData else {
            dataInfoLabel.text = "暂无数据".localized()
            return
        }
        
        let size = pcmData.count
        var sizeText = ""
        
        if size < 1024 {
            sizeText = "\(size) B"
        } else if size < 1024 * 1024 {
            let kb = Double(size) / 1024.0
            sizeText = String(format: "%.1f KB", kb)
        } else {
            let mb = Double(size) / (1024.0 * 1024.0)
            sizeText = String(format: "%.1f MB", mb)
        }
        
        dataInfoLabel.text = "\("音频数据".localized())：\(sizeText)"
    }
}

// MARK: - AVAudioPlayerDelegate
extension AiChatVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        hidePlayingStatus()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        hidePlayingStatus()
        showToast("音频解码错误".localized())
    }
}

extension AiChatVC: WMAiAssistantDelegate {
    func glassesSendData(withImageData imageData: Data?, pcmData: Data?) {
    }
    
    func glassesSendAudio(withPcmData pcmData: Data) {
        self.debugPCMData?.append(pcmData)
        updateDataInfo()
    }
    
    func glassesSendImage(withImageData imageData: Data?) {
        guard let imageData = imageData else { return }
        previewImageView.image = UIImage(data: imageData)
    }
    
    func openAiAssistant() {
        self.debugPCMData = Data()
        updateDataInfo()
    }
    
    func closeAiAssistant() {
        updateDataInfo()
    }
    
    private func convertPCMToWAV(pcmData: Data) -> Data? {
        // WAV文件头结构
        let sampleRate: UInt32 = 16000
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = sampleRate * UInt32(numChannels) * UInt32(bitsPerSample / 8)
        let blockAlign = numChannels * bitsPerSample / 8
        
        // 计算文件大小
        let pcmDataSize = UInt32(pcmData.count)
        let headerSize: UInt32 = 44  // WAV标准头大小
        let totalSize = headerSize + pcmDataSize - 8 // RIFF chunk size (总大小 - 8)
        
        var headerData = Data()
        
        // RIFF Chunk
        headerData.append("RIFF".data(using: .utf8)!)
        headerData.append(withUnsafeBytes(of: totalSize.littleEndian) { Data($0) })
        headerData.append("WAVE".data(using: .utf8)!)
        
        // fmt Chunk
        headerData.append("fmt ".data(using: .utf8)!)
        let fmtChunkSize: UInt32 = 16
        headerData.append(withUnsafeBytes(of: fmtChunkSize.littleEndian) { Data($0) })
        
        // Audio Format (PCM = 1)
        let audioFormat: UInt16 = 1
        headerData.append(withUnsafeBytes(of: audioFormat.littleEndian) { Data($0) })
        
        // Number of channels
        headerData.append(withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        
        // Sample Rate
        headerData.append(withUnsafeBytes(of: sampleRate.littleEndian) { Data($0) })
        
        // Byte Rate
        headerData.append(withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        
        // Block Align
        headerData.append(withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        
        // Bits Per Sample
        headerData.append(withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        
        // Data Chunk
        headerData.append("data".data(using: .utf8)!)
        headerData.append(withUnsafeBytes(of: pcmDataSize.littleEndian) { Data($0) })
        
        // 合并头信息和PCM数据
        var wavData = Data()
        wavData.append(headerData)
        wavData.append(pcmData)
        
        return wavData
    }
}


