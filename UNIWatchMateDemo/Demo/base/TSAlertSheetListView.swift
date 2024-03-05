//
//  TSAlertSheetListView.swift
//  OraimoHealth
//
//  Created by tanghan on 2021/12/27.
//  Copyright © 2021 Transsion-Oraimo. All rights reserved.
//

import UIKit

class TSAlertSheetListView: BaseView {
    lazy var tableView: UITableView = {
        let tb = UITableView.init(frame: .zero, style: .plain)
        tb.backgroundColor = .clear
        tb.separatorStyle = .singleLine
        tb.separatorColor = .color333333
        tb.separatorInset = .zero
        tb.bounces = false
        return tb
    }()
    
    private var _items:[String] = [] {
        didSet {
            contentView.snp.updateConstraints {
                $0.height.equalTo(70 + 80 * CGFloat(_items.count))
            }
        }
    }
    private var _selectBlock:CommonIntBlock?
    private lazy var contentView:UIView = UIView.init()
    
    convenience init(items: [String] , completion:CommonIntBlock?) {
        self.init(frame: .zero)
        _items = items
        _selectBlock = completion
        
        contentView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(70 + 80 * _items.count)
            $0.bottom.equalToSuperview().offset(-bottomSafeHeight - 10)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        self.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        let bgView = UIView.init()
        bgView.backgroundColor = .colorFFFFFF.withAlphaComponent(0.7)
        addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(70 + 80 * _items.count)
            $0.bottom.equalToSuperview().offset(-bottomSafeHeight - 10)
        }

        let cannelItem = UIButton(title: "取消", textColor: .color000000, font: .medium18(), target: self, selector: #selector(cannelAction))
        cannelItem.backgroundColor = .colorFFFFFF
        cannelItem.cornerRadius = 10
        contentView.addSubview(cannelItem)
        cannelItem.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(10)
            $0.height.equalTo(60)
        }
        
        contentView.addSubview(tableView)
        tableView.cornerRadius = 10
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalTo(cannelItem.snp.top).offset(-9)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(cellWithClass: TSAlertSheetListCell.self)
    }
    
    @objc func cannelAction() {
        dimiss()
    }
}

extension TSAlertSheetListView : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: TSAlertSheetListCell.self, for: indexPath)
        cell.tittleLB.text = _items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dimiss()
        _selectBlock?(indexPath.row)
    }
    
}

extension TSAlertSheetListView {
    public func dimiss() {
        UIView.animate(withDuration: 0.25) {
            var rect = self.contentView.frame
            rect.origin.y = screenHeight
            self.contentView.frame = rect
        } completion: { finish in
            self.removeFromSuperview()
        }
    }
    
    public func show() {
        keyWindow?.addSubview(self)
        self.layoutIfNeeded()
        contentView.frame.origin.y = screenHeight
        UIView.animate(withDuration: 0.25) {
            var rect = self.contentView.frame
            rect.origin.y = screenHeight - rect.height - bottomSafeHeight
            self.contentView.frame = rect
        } completion: { finish in
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touchView = touches.first?.view
        if touchView?.isDescendant(of: contentView) != true {
            self.dimiss()
        }
    }
}


class TSAlertSheetListCell: BaseTableViewCell {
    lazy var tittleLB:UILabel = UILabel.init(text: "", textColor: .color000000, font: .medium18())
    override func setupUI() {
        super.setupUI()
        backgroundColor = .colorFFFFFF
        selectionStyle = .none
        contentView.addSubview(tittleLB)
        tittleLB.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
