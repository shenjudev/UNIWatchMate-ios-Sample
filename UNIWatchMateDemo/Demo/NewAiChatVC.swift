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
import MZEncryptSDK

//长对话AI聊天流程。
//1.通过语音唤醒进入语音聊天模式（不间断对话），APP端收到openAiAssistantNew()回调，设备端开始录音。glassesSendAudioNew()回调收到解码后的pcm数据。
//2. 设备端通过vad检测到没有人声的时候，APP收到stopAudioSendAiAssistantNew()回调， 告诉手机本次说话完成。
//3. 手机端收到stopAudioSendAiAssistantNew()回调后开始调用大模型对话，App在开始播放tts时调用appBeginPlayTts()命令到设备端，设备端将忽略有人说话并不再采集语音数据
//4. 手机端播放tts完成后，给设备端发送appStopPlayTts()方法表示手机tts播放完成，此时设备又重新开始采集语音数据
//5. 在聊天过程中，手机端可以调用appStopAiChat()给设备来结束语音聊天
//6. 设备端在6秒内如果检测不到声音设备主动退出聊天模式（再次进入聊天需要语音唤醒）
//7. 手机端可以调用letDeviceTakePhotoInChat()方法，让设备拍照并将数据传输给APP，glassesSendImageNew方法可以收到图片数据
//8.语音唤醒或设备按键时，可以打断当前ai对话，此时会收到closeAiAssistantNew()的回调

//离线语音sdk的使用
//1.1 导包：导⼊MZEncryptSDK.framework 、OpenSSL-Universal 、AFNetworking.
//1.2 设置：target -> Build Settings -> Bitcode设置为NO, Other Linker Flags添加-ObjC
//需要注意 默认语音应该是英文，中文唤醒词唤醒不了
class NewAiChatVC: UIViewController {

    var disposable: RACDisposable?
    var isOnResume = false
    private var debugPCMData: Data?
    private var audioPlayer: AVAudioPlayer?
    

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
    
    private lazy var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("设备拍照并传输".localized(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemGray
        button.isUserInteractionEnabled = false
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(takePhotoButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
    
    private lazy var voiceWakeupLabel: UILabel = {
        let label = UILabel()
        label.text = "离线语音唤醒".localized()
        label.textColor = .darkGray
        label.isHidden = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var voiceWakeupSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .systemBlue
        switchControl.isHidden = false
        switchControl.addTarget(self, action: #selector(voiceWakeupSwitchChanged), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var voiceSupportLabel: UILabel = {
        let label = UILabel()
        label.text = "设备支持离线语音".localized()
        label.textColor = .darkGray
        label.isHidden = false
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var voiceSupportImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = false
        imageView.tintColor = .systemGreen
        return imageView
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
        appStopAiChat()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
        //self.addNotice()
        }
        setupUI()
        
        WatchManager.sharedInstance().current.subscribeNext { wMPeripheral in
            wMPeripheral?.aiNewAssistantDelegate = self
            wMPeripheral?.customDataDelegate = self
            MZPayAuth.share().logEnable = true
            print("wMPeripheral?.connect.isReadyValue = \(wMPeripheral?.connect.isReadyValue ?? false)")

            //设备绑定成功后调用
            
            if wMPeripheral?.connect.isReadyValue ?? false {
                wMPeripheral?.infoModel.wm_getBaseinfo().subscribeNext({[weak self] baseInfo in
                    guard let self = self else{return}
                    //设备基本信息中的offline_asr_auth 为"1",说明设备离线语音已经激活，不需要二次激活
                    let offline_asr_auth = baseInfo?.otherInfo?["offline_asr_auth"] ?? "-1"
                    print("offline_asr_auth = \(offline_asr_auth)")
                    if offline_asr_auth as! String != "1" {
                        //说明离线语音没有售全国
                        //mac地址需要 离线语音提供商 授权，才能正常激活
                        MZPayAuth.share().auth(withMac: wMPeripheral?.target.mac ?? "", name: wMPeripheral?.target.name ?? "", delegate: self)

                    }
                }, error: { error in
                    
                }, completed: {
                    
                })
            }
            
//             检查设备是否支持离线语音
            self.checkVoiceSupportStatus()
            // 获取当前离线语音唤醒状态
            self.getVoiceWakeupStatus()
        }
       
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "新AI对话".localized()
        view.addSubview(containerView)
        containerView.addSubview(previewImageView)
        view.addSubview(aiButton)
        view.addSubview(takePhotoButton)
        view.addSubview(statusLabel)
        view.addSubview(dataInfoLabel)
        view.addSubview(voiceSupportLabel)
        view.addSubview(voiceSupportImageView)
        view.addSubview(voiceWakeupLabel)
        view.addSubview(voiceWakeupSwitch)
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
            make.width.equalTo(120)
            make.height.equalTo(36)
            make.top.equalTo(containerView.snp.bottom).offset(20)
        }
        
        takePhotoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(containerView.snp.top).offset(-20)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(aiButton.snp.bottom).offset(8)
        }
        
        dataInfoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
        }
        
        voiceSupportLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(voiceWakeupLabel.snp.top).offset(-20)
        }
        
        voiceSupportImageView.snp.makeConstraints { make in
            make.leading.equalTo(voiceSupportLabel.snp.trailing).offset(10)
            make.centerY.equalTo(voiceSupportLabel.snp.centerY)
            make.width.height.equalTo(24)
        }
        
        voiceWakeupLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
        }
        
        voiceWakeupSwitch.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(voiceWakeupLabel.snp.bottom).offset(12)
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
    
    @objc private func takePhotoButtonTapped() {
        // 添加点击反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.takePhotoButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.takePhotoButton.transform = .identity
            }
        }
        
        // 调用设备拍照功能
        WatchManager.sharedInstance().currentValue.apps.aiNewAssist.letDeviceTakePhotoInChat().subscribeNext { result in
            if result == 0 {
                self.showToast("拍照指令已发送".localized())
            } else {
                self.showToast("拍照指令发送失败".localized())
            }
        } completed: {
            // 完成回调
        }
    }
    
    @objc private func voiceWakeupSwitchChanged(_ sender: UISwitch) {
        let isOn = sender.isOn
        showToast(isOn ? "正在开启离线语音唤醒..." : "正在关闭离线语音唤醒...")
        
        // 设置离线语音唤醒开关
        WatchManager.sharedInstance().currentValue.apps.aiNewAssist.setVoiceWakeupOpen(isOn ? 1 : 0).subscribeNext { result in
            if result == 0 {
                self.showToast(isOn ? "离线语音唤醒已开启" : "离线语音唤醒已关闭")
            } else {
                // 设置失败，恢复开关状态
                sender.setOn(!isOn, animated: true)
                self.showToast("设置失败，请重试")
            }
        } completed: {
            // 完成回调
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
    
    private func getVoiceWakeupStatus() {
        WatchManager.sharedInstance().currentValue.apps.aiNewAssist.getVoiceWakeupOpen().subscribeNext { result in
            // 根据返回结果设置开关状态
            self.voiceWakeupSwitch.isOn = (result == 0)
        } completed: {
            // 完成回调
        }
    }
    
    private func checkVoiceSupportStatus() {
        let isSupported = WatchManager.sharedInstance().currentValue.infoModel.glassesFeatureSetModel?.feature_mask.isFeatureEnabled(.featureWakeupWord) ?? false
        
        if isSupported {
            voiceSupportImageView.image = UIImage(systemName: "checkmark.circle.fill")
            voiceSupportImageView.tintColor = .systemGreen
        } else {
            voiceSupportImageView.image = UIImage(systemName: "xmark.circle.fill")
            voiceSupportImageView.tintColor = .systemRed
        }
    }
    //退出ai对话模式
    private func appStopAiChat() {
        WatchManager.sharedInstance().currentValue.apps.aiNewAssist.appStopAiChat().subscribeNext { result in
            // 根据返回结果设置开关状态  0: 成功1: 失败
            DDLogInfo("appStopAiChat result\(result)");

        } completed: {
            // 完成回调
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension NewAiChatVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        hidePlayingStatus()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        hidePlayingStatus()
        showToast("音频解码错误".localized())
    }
}

extension NewAiChatVC: WMNewAiAssistantDelegate {
    func stopAudioSendAiAssistantNew() {
        //本次语音结束，停止向app发送音频数据
        print("stopAudioSendAiAssistantNew  本次语音结束")

        statusLabel.text = "本次语音结束"
        updateDataInfo()
        takePhotoButton.backgroundColor = .systemBlue
        takePhotoButton.isUserInteractionEnabled = true
          
          //模拟收到对话结果
  //        showToast("app开始播放tts,模拟耗时 5秒后向设备发送 结束播放TTS 通知")
  //        // app开始播放tts，5秒后向设备发送 结束播放TTS 通知，之后设备打开录音
  //        WatchManager.sharedInstance().currentValue.apps.aiNewAssist.appBeginPlayTts().subscribeNext { rs in
  //            if rs == 0 {
  //                //成功
  //            }
  //        } completed: {
  //
  //        }
  //
  //        DispatchQueue.main.asyncAfter(deadline: .now()+5){[weak self] in
  //            // 5秒后向设备发送 结束播放TTS 通知 之后设备打开录音
  //            self?.showToast("设备发送 结束播放TTS 通知,设备开始录音")
  //            WatchManager.sharedInstance().currentValue.apps.aiNewAssist.appStopPlayTts().subscribeNext { rs in
  //                if rs == 0 {
  //                    //成功
  //                    self?.debugPCMData = Data()
  //                    self?.updateDataInfo()
  //                    statusLabel.text = "设备正在录音..."
  //                }
  //            } completed: {
  //
  //            }
  //        }
    }
    
    
    func glassesSendDataNew(withImageData imageData: Data?, pcmData: Data?) {
    }
    
    func glassesSendAudioNew(withPcmData pcmData: Data) {
        self.debugPCMData?.append(pcmData)
        updateDataInfo()
    }
    
    func glassesSendImageNew(withImageData imageData: Data?) {
        guard let imageData = imageData else { return }
        previewImageView.image = UIImage(data: imageData)
    }
    
    func openAiAssistantNew() {
        statusLabel.text = "设备正在播放录音..."
        self.debugPCMData = Data()
        updateDataInfo()
    }
    
    func closeAiAssistantNew() {
        //设备退出ai聊天 ，打断AI对话时，会回调到
        print("closeAiAssistantNew  设备退出ai聊天")
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

extension NewAiChatVC: MZPayAuthDelegate{
    func mzPayAuthWriteValue(_ data: Data) {
        //将数据发送给设备
        DDLogInfo("离线语音验证收到数据，发送给设备,data大小 \(data.count)");
        var sendData = Data()
        sendData.append(UInt8(2))
        sendData.append(data)
        //收到设备的数据后，通过MZPayAuth.parseData方法将数据传给MZEncryptSDK
        WatchManager.sharedInstance().currentValue.sendCustomData(sendData)
    }
    
//    func onCheckAuthoriseState(_ error: MZPayAuthError) {
//        DDLogInfo("离线语音验证 onCheckAuthoriseState\(error.result)  \(error.type)")
//    }
    
    func onCheckAuthoriseResult(_ result: MZAuthResult) {
     
        if (result.payAuthResult != nil) {
            if (result.payAuthResult!.result == MZPayAuthResult.success) {
                DDLogInfo("双付验证成功");
            } else if (result.payAuthResult!.result == MZPayAuthResult.failure) {
                DDLogInfo("双付验证失败,errorCode = \(result.payAuthResult!.errorCode)");
            } else {
                DDLogInfo("双付验证失败,未知错误");
            }
        }
        
        if (result.voiceOfflineAuthResult != nil&&result.payAuthResult != nil) {
            if (result.payAuthResult!.result == MZPayAuthResult.success) {
                DDLogInfo("离线语音验证成功");
            } else if (result.payAuthResult!.result == MZPayAuthResult.failure) {
                DDLogInfo("离线语音验证失败,errorCode = \(result.voiceOfflineAuthResult!.errorCode)");
            } else {
                DDLogInfo("离线语音验证失败,未知错误");
            }
        }
    }
}


extension NewAiChatVC: WMCustomDataDelegate {
    func devicePushDataNeedReply(_ data: Data, result: @escaping (Bool) -> Void) {
        result(true)
        DispatchQueue.main.async {
        }
    }
    
    func devicePush(_ deviceData: Data) {
        DispatchQueue.main.async {
           if deviceData.count > 1 , deviceData[0] == 2 {
                let receiveData =  deviceData[1..<deviceData.count]
                let receiveDataString  = receiveData.toHexString()
                DDLogInfo("glasses receive device data 收到离线语音验证数据 MZPayAuth.share().parseData  = \(String(describing: receiveDataString))")
                MZPayAuth.share().parseData(receiveData)
            }else{
                DDLogInfo("StarburstSdk  glasses deviceData = \(deviceData.toHexString())")
            }
        }
    }
}

extension Data {
 

  public var bytes: Array<UInt8> {
    Array(self)
  }

  public func toHexString() -> String {
    self.bytes.toHexString()
  }
}


extension Array where Element == UInt8 {
  public init(hex: String) {
    self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
    var buffer: UInt8?
    var skip = hex.hasPrefix("0x") ? 2 : 0
    for char in hex.unicodeScalars.lazy {
      guard skip == 0 else {
        skip -= 1
        continue
      }
      guard char.value >= 48 && char.value <= 102 else {
        removeAll()
        return
      }
      let v: UInt8
      let c: UInt8 = UInt8(char.value)
      switch c {
        case let c where c <= 57:
          v = c - 48
        case let c where c >= 65 && c <= 70:
          v = c - 55
        case let c where c >= 97:
          v = c - 87
        default:
          removeAll()
          return
      }
      if let b = buffer {
        append(b << 4 | v)
        buffer = nil
      } else {
        buffer = v
      }
    }
    if let b = buffer {
      append(b)
    }
  }

  public func toHexString() -> String {
    `lazy`.reduce(into: "") {
      var s = String($1, radix: 16)
      if s.count == 1 {
        s = "0" + s
      }
      $0 += s
    }
  }
}

