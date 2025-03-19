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
import SnapKit

class CustomDataVC: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Elements
    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "请输入要发送的数据".localized()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 15)
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\("发送".localized())(0x0003)", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private lazy var sendWithoutResponseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("\("无回复发送".localized())(0x0004)", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        return button
    }()
    
    private lazy var receivedDataLabel: UILabel = {
        let label = UILabel()
        label.text = "\("接收到的数据".localized())："
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var receivedDataTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.isEditable = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        WatchManager.sharedInstance().current.subscribeNext { wMPeripheral in
            wMPeripheral?.customDataDelegate = self
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "自定义数据".localized()
        
        view.addSubview(inputTextField)
        view.addSubview(sendButton)
        view.addSubview(sendWithoutResponseButton)
        view.addSubview(receivedDataLabel)
        view.addSubview(receivedDataTextView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        inputTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16) // 增加间距以适应两个按钮
            make.height.equalTo(40)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(inputTextField.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.width.equalTo(105)
            make.height.equalTo(inputTextField)
        }
        
        sendWithoutResponseButton.snp.makeConstraints { make in
            make.top.equalTo(sendButton)
            make.leading.equalTo(sendButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(inputTextField)
        }
        
        receivedDataLabel.snp.makeConstraints { make in
            make.top.equalTo(sendButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        receivedDataTextView.snp.makeConstraints { make in
            make.top.equalTo(receivedDataLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // 普通发送按钮点击事件
        sendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendData(withResponse: true)
            })
            .disposed(by: disposeBag)
        
        // 无回复发送按钮点击事件
        sendWithoutResponseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.sendData(withResponse: false)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    private func sendData(withResponse: Bool) {
        guard let inputText = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !inputText.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入要发送的数据".localized())
            return
        }
        
        guard let data = inputText.data(using: .utf8) else {
            SVProgressHUD.showError(withStatus: "数据转换失败".localized())
            return
        }
        var sendData = Data()
        sendData.append(UInt8(1))
        sendData.append(data)
        if withResponse {
            SVProgressHUD.show(withStatus: "发送中...".localized())
            WatchManager.sharedInstance().currentValue.sendCustomDataNeedReply(sendData).subscribeNext {[weak self] result in
                SVProgressHUD.dismiss()
                DDLogInfo("sendCustomDataNeedReply result = \(String(describing: result))")
                guard self != nil else { return }
                if result?.boolValue ?? false  {
                    DDLogInfo("deviceTakePhoto 发送成功")
                    SVProgressHUD.showSuccess(withStatus: "发送成功".localized())
                }else {
                    SVProgressHUD.showError(withStatus: "发送失败".localized())
                }
            } error: { error in
                SVProgressHUD.showError(withStatus: "发送失败 error = \(String(describing: error?.localizedDescription))")
                DDLogInfo(error as Any)
                SVProgressHUD.dismiss()
            }
        } else {
            SVProgressHUD.show(withStatus: "发送中...".localized())
            WatchManager.sharedInstance().currentValue.sendCustomData(sendData)
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: "发送完毕".localized())
        }
    }
}

extension CustomDataVC: WMCustomDataDelegate {
    func devicePushDataNeedReply(_ data: Data, result: @escaping (Bool) -> Void) {
        result(true)
        DispatchQueue.main.async {
            self.receivedDataTextView.text = "0X0001 - receiveData: \(data.toHexString2())"
        }
    }
    
    func devicePush(_ data: Data) {
        DispatchQueue.main.async {
            self.receivedDataTextView.text = "0X0002 - receiveData: \(data.toHexString2())"
        }
    }
}

