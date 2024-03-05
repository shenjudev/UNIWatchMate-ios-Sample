//
//  TSDailCustomPreviewCell.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/12/27.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import UIKit
import AVFoundation

class TSLoopVideoView: UIView {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    // 设置视频播放器
    func setupVideoPlayer(url: URL) {
        self.playerLayer?.removeFromSuperlayer()
        // 创建播放器
        player = AVPlayer(url: url)
        player?.volume = 0
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = self.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }

        // 循环播放的通知
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loopVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        self.play()
    }

    // 视图布局变化时更新播放器图层的frame
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
    // 视频播放结束时循环播放
    @objc func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    // 开始播放视频
    func play() {
        player?.play()
    }

    // 停止播放视频
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }

    // 销毁时移除通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class TSDailCustomPreviewView: UICollectionViewCell {
    lazy var dailIcon:UIImageView = UIImageView.init()
    lazy var timeIcon:UIImageView = UIImageView.init()
    lazy var videoPreviewView = TSLoopVideoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadVideoIfNeed(model: TSWatchDailModel?) {
        guard let model = model,
              model.isVideo,
              let _ = try? Data(contentsOf: .init(fileURLWithPath: model.filePath)) else {
            self.videoPreviewView.isHidden = true
            self.dailIcon.isHidden = false
            self.videoPreviewView.stop()
            return
        }
        self.videoPreviewView.isHidden = false
        self.dailIcon.isHidden = true
        
        self.videoPreviewView.setupVideoPlayer(url: .init(fileURLWithPath: model.filePath))
    }
}

extension TSDailCustomPreviewView {
   
    private func setupUI() {
      //  dailIcon.backgroundColor = UIColor(hexString: "#3B3A3A")
        contentView.addSubview(videoPreviewView)
        contentView.addSubview(dailIcon)

        let top = 40.0
        let width = 120.0
        let height = 140.0
        var cornerRadius = TSDeviceDialTools.shared.getcornerRadii()
//        switch dailStyle {
//        case .square:
//             top = 40.0
//             width = 120.0
//             height = 140.0
            cornerRadius = 15.0
//        case .circular:
//             top = 10.0
//             width = 180.0
//             height = 180.0
//            cornerRadius = width * 0.5
//        }
        dailIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(top)
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        videoPreviewView.snp.makeConstraints { make in
            make.edges.equalTo(dailIcon)
        }
        
        timeIcon.backgroundColor = .clear
        contentView.addSubview(timeIcon)
        
        timeIcon.snp.makeConstraints {
            $0.edges.equalTo(dailIcon)
        }
        
        contentView.layoutIfNeeded()
        timeIcon.borderWidth = 1
        timeIcon.borderColor = .color000000
        timeIcon.cornerRadius = cornerRadius
        dailIcon.cornerRadius = cornerRadius
        videoPreviewView.cornerRadius = cornerRadius

    }
}

class TSDailCustomPreviewCell: UICollectionViewCell {
    lazy var dailIcon:UIImageView = UIImageView.init()
    lazy var timeIcon:UIImageView = UIImageView.init()
    lazy var tipsLB : UILabel = UILabel.init(text: "", textColor: .colorFFFFFF, font: .medium16())
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TSDailCustomPreviewCell {
   
    private func setupUI() {
        
        self.contentView.layoutIfNeeded()

//        let dailStyle = getDeviceType().getDialAppearanceType
        var top = 50.0
        var width = 120.0
        var height = 140.0
        var bottom = -16.0
        var cornerRadius = 15.0
//        switch dailStyle {
            top = 40.0
            width = 120.0
            height = 140.0
            cornerRadius = 15.0
            bottom = -16.0
        dailIcon.backgroundColor = UIColor(hexString: "#3B3A3A")
        contentView.addSubview(dailIcon)
        dailIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(top)
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }

        timeIcon.backgroundColor = .clear
        dailIcon.addSubview(timeIcon)
        timeIcon.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
        contentView.addSubview(tipsLB)
        tipsLB.snp.makeConstraints {
            $0.centerX.equalTo(dailIcon.snp.centerX)
            $0.bottom.equalTo(dailIcon.snp.bottom).offset(bottom)
        }
        
        dailIcon.cornerRadius = cornerRadius

    }
}

// MARK: 自定义表盘组头
class TSDailCustomHeadView: UICollectionReusableView {
    lazy var titleLB:UILabel = UILabel.init(text: "Custom Background", textColor: .color000000, font: .medium16())
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLB)
        titleLB.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().offset(-18)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: 自定义表盘背景
class TSDailCustomBgCell: UICollectionViewCell {
    lazy var dialBgIcon:UIImageView = UIImageView(image: UIImage(named: "ic_dail_add"))
    lazy var tihuanIcon:UIImageView = UIImageView.init(image: UIImage(named: "ic_dail_tihuan"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let dailStyle = getDeviceType().getDialAppearanceType
        var cornerRadius = 15.0
        var itemHeight: CGFloat = 0
//        switch dailStyle{
//        case .square:
            cornerRadius = 15.0
            itemHeight = self.width * (112 / 98.0)

//        case .circular:
//            itemHeight = self.width
//            cornerRadius = self.width * 0.5
//        }
        
        contentView.addSubview(dialBgIcon)
        
        dialBgIcon.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(itemHeight)
        }
        
        contentView.layoutIfNeeded()
        dialBgIcon.cornerRadius = cornerRadius

        contentView.addSubview(tihuanIcon)
        tihuanIcon.isHidden = true
        tihuanIcon.snp.makeConstraints {
            $0.width.height.equalTo(25)
            $0.bottom.equalTo(dialBgIcon.snp.bottom).offset(3)
            $0.trailing.equalTo(dialBgIcon.snp.trailing).offset(12)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: 自定义表盘时间格式横向滚动
class TSDailCustomCollectionTimeStyleCell: UICollectionViewCell, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.register(cellWithClass: TSDailCustomTimeStyleCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var timeImages: [UIImage] = []
    private var currentTimeIndexPath : IndexPath = NSIndexPath(item: 0, section: 0) as IndexPath
    private var timeStyleChangeBlock : ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.contentView.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: TSDailCustomTimeStyleCell.self, for: indexPath)
        cell.dailImg.image = self.timeImages[indexPath.row].withTintColor(.color000000)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 108, height: 122)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == currentTimeIndexPath.item {return}
        collectionView.deselectItem(at: currentTimeIndexPath, animated: false)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        currentTimeIndexPath = indexPath
        self.timeStyleChangeBlock?(indexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
    }
    
    func setView(timeImages: [UIImage], timeStyleChange: @escaping (Int) -> Void) {
        self.timeImages = timeImages
        self.collectionView.reloadData()
        self.currentTimeIndexPath = NSIndexPath(item: 0, section: 0) as IndexPath
        self.collectionView.selectItem(at: currentTimeIndexPath, animated: true, scrollPosition: .left)
        self.timeStyleChangeBlock = timeStyleChange
    }
}


// MARK: 自定义表盘字体颜色

class TSDailCustomTimeStyleCell: UICollectionViewCell {
    
    lazy var dailImg:UIImageView = UIImageView(image: UIImage(named: "ic_bolt_circle_fill")?.withTintColor(.color000000))
    lazy private var selectView:UIView = UIView.init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectView.isHidden = false
            }else {
                selectView.isHidden = true
            }
        }
    }
}

extension TSDailCustomTimeStyleCell {
   
    private func setupUI() {
        
//        let dailStyle = getDeviceType().getDialAppearanceType
//        var height = 112.0
//        var width = 98.0
        var cornerRadius = 15.0
        var smalCcornerRadius = 15.0
//        switch dailStyle {
//        case .square:
            cornerRadius = 15
            smalCcornerRadius = 15
//        case .circular:
//            height = 112.0
//            width = 112.0
//            cornerRadius = self.width * 0.5
//            smalCcornerRadius = 112.0 / 2
//        }

        contentView.addSubview(dailImg)
       
        
        dailImg.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        
        selectView.isHidden = true
        contentView.addSubview(selectView)
        selectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.layoutIfNeeded()
        
        dailImg.cornerRadius = smalCcornerRadius
        dailImg.borderWidth = 1
        dailImg.borderColor = .color000000
        
        selectView.cornerRadius = cornerRadius
        selectView.borderWidth = 2
        selectView.borderColor = .colorC5A5FF
    }
}


// MARK: 自定义表盘字体颜色

class TSDailCustomFontColorCell: UICollectionViewCell {
    
    var colorStr : String? {
        didSet {
            if (colorStr?.count ?? 0) > 0 {
                colorView.backgroundColor = UIColor(hexString: colorStr ?? "")
                colorImg.isHidden = true
                colorView.isHidden = false
            }else{
                colorImg.isHidden = false
                colorView.isHidden = true
            }
        }
    }
    
    var cellColor : UIColor = .white {
        didSet {
            if cellColor == UIColor.clear {
                colorImg.isHidden = false
                colorView.isHidden = true

            }
            else {
                colorView.backgroundColor = cellColor
                colorImg.isHidden = true
                colorView.isHidden = false
            }
        }
    }
    
    lazy private var colorView:UIView = UIView.init()
    lazy private var colorImg:UIImageView = UIImageView(image: UIImage(named: "ic_dail_color_item"))
    lazy private var selectView:UIView = UIView.init()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectView.isHidden = false
            }else {
                selectView.isHidden = true
            }
        }
    }
}

extension TSDailCustomFontColorCell {
   
    private func setupUI() {
        

        contentView.addSubview(colorView)
        
        colorView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().offset(-3)
            $0.top.equalToSuperview().offset(3)
            $0.bottom.equalToSuperview().offset(-3)
        }
        
        contentView.addSubview(colorImg)
        
        colorImg.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().offset(-4)
            $0.top.equalToSuperview().offset(3)
            $0.bottom.equalToSuperview().offset(-3)
        }
        
        selectView.isHidden = true
        contentView.addSubview(selectView)
        selectView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }
        
        contentView.layoutIfNeeded()
        
        colorView.cornerRadius = colorView.width / 2
        colorImg.cornerRadius = colorImg.width / 2
        selectView.cornerRadius = selectView.width / 2
        selectView.borderWidth = 1
        selectView.borderColor = .colorFFFFFF
    }
}
