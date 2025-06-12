import UIKit
import SnapKit

class PhotoLibraryOperationView: SJBaseView {
    let tipImage = UIImageView().tt_image(UIImage(named: "import_img_tip"))
    let loadingImage = UIImageView().tt_image(UIImage(named: "ic_import_loading"))
    let titleLb = UILabel().tt_font(.pingFangSC_Regular(16)).tt_textColor(.white).tt_text("照片导入手机").tt_numberOfLines(0)
    
    let importLb = UILabel().tt_font(.pingFangSC_Regular(16)).tt_textColor(.white)
    let importTipLb = UILabel().tt_font(.pingFangSC_Regular(16)).tt_textColor(.white).tt_text("请勿离开应用").tt_numberOfLines(0)
    
    let importBtn = UIButton()
        .tt_text("导入")
        .tt_textColor(.black)
        .tt_font(.pingFangSC_Regular(14))
        .tt_color(.white)
        .tt_radius(9)
        .tt_contentEdgeInsets(.init(top: 0, left: 25, bottom: 0, right: 25))
    var tapCount = 0 // 添加点击计数器
    var lastTapTime: TimeInterval = 0 // 添加最后点击时间记录
    
    private func startLoadingAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 2.0
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.isRemovedOnCompletion = false
        loadingImage.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopLoadingAnimation() {
        loadingImage.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    override func appendUI() {
        // 设置内容压缩阻力优先级 - 关键设置
        // 让右边标签的压缩阻力更高，这样它不会被压缩
        importBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLb.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        importLb.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        importTipLb.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 设置内容拉伸优先级
        // 让左边标签的拉伸优先级更高，允许它填充多余空间
        importLb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        importTipLb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLb.setContentHuggingPriority(.defaultLow, for: .horizontal)
        importBtn.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addSubview(titleLb)
        addSubview(importBtn)
        addSubview(tipImage)
        addSubview(loadingImage)
        addSubview(importLb)
        addSubview(importTipLb)
        showImporting(false)
    }
    override func layoutUI() {
     
        importBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }
        
        tipImage.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(19)
        }
        
        loadingImage.snp.makeConstraints { make in
            make.leading.equalTo(18)
            make.width.height.equalTo(25)
            make.centerY.equalToSuperview()
        }
        
        titleLb.snp.makeConstraints { make in
            make.leading.equalTo(tipImage.snp.trailing).offset(6)
            make.top.equalTo(13)
            make.bottom.equalTo(-13)
            make.trailing.lessThanOrEqualTo(importBtn.snp.leading).offset(-2)
        }
        
        importLb.snp.makeConstraints { make in
            make.leading.equalTo(loadingImage.snp.trailing).offset(16)
            make.top.equalTo(13)
            make.bottom.equalTo(importTipLb.snp.top)
            make.trailing.lessThanOrEqualTo(importBtn.snp.leading).offset(-2)
        }
        
        importTipLb.snp.makeConstraints { make in
            make.leading.equalTo(importLb)
            make.top.equalTo(importLb.snp.bottom)
            make.bottom.equalTo(-13)
            make.trailing.lessThanOrEqualTo(importBtn.snp.leading).offset(-2)
        }
    }
    
    override func layoutSubviews() {
        DispatchQueue.main.async {
        }
    }
    
    func showImporting(_ importing: Bool){
        importBtn.setTitle(importing ? "终止" : "导入", for: .normal)
        tipImage.isHidden = importing
        titleLb.isHidden = importing
        
        loadingImage.isHidden = !importing
        importLb.isHidden = !importing
        importTipLb.isHidden = !importing
        
        if importing {
            startLoadingAnimation()
        } else {
            stopLoadingAnimation()
        }
    }
}

