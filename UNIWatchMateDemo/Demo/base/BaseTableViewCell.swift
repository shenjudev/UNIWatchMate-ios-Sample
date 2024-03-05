//
//  BaseTableViewCell.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/3/1.
//

import Foundation
import UIKit

class BaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
        self.setupUI()
    }
    
    func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
    }
    
}
