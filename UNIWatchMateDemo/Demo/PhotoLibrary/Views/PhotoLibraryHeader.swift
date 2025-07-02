import UIKit
import SnapKit

class PhotoLibraryHeader: SJBaseView {
    let naviBar = UIView()
    let titleLb = UILabel().tt_font(.pingFangSC_Medium(18)).tt_textColor(.white).tt_text("相册")
    let backBtn = UIButton() .tt_image(UIImage(named: "ic_topnav_back_arr_40_active"), for: .normal)
    
    let selectModeBtn = UIButton()
        .tt_image(UIImage(named: "ic_check_34"), for: .normal)
        .tt_image(UIImage(named: "ic_check_green_34"), for: .selected)
    
    var tapCount = 0 // 添加点击计数器
    var lastTapTime: TimeInterval = 0 // 添加最后点击时间记录
    
    override func appendUI() {
        addSubview(naviBar)
        addSubview(titleLb)
        addSubview(backBtn)
        addSubview(selectModeBtn)
        
        // 添加按钮点击事件
    }

    
    override func layoutUI() {
        naviBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        titleLb.snp.makeConstraints { make in
            make.left.equalTo(backBtn.snp.right).offset(16)
            make.centerY.equalTo(naviBar)
        }
   
        backBtn.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(naviBar)
            make.width.height.equalTo(44)
        }
        selectModeBtn.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(naviBar)
            make.width.height.equalTo(34)
        }
    }
    
    
}
