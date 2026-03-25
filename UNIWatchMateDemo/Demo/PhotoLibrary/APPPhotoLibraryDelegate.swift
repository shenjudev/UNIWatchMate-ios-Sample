//
//  APPPhotoLibraryDelegate.swift
//  LensMoo
//
//  Created by qiyachao on 2025/8/27.
//  Copyright © 2025 LensMoo. All rights reserved.
//

import Foundation

/// APPPhotoLibraryService的代理协议
@objc protocol APPPhotoLibraryDelegate: AnyObject {
    
    /// 设备发送图片名称数据
    /// - Parameter imageNamesData: 图片名称数据
    @objc optional func appPhotoLibraryDidReceiveImageNames(_ imageNamesData: Data?)
    
    /// 设备发送图片数据
    /// - Parameter imageData: 图片数据
    @objc optional func appPhotoLibraryDidReceiveImage(_ imageData: Data?)
    
    
    /// 接收到新照片
    /// - Parameter imageURL: 新照片的URL
    @objc optional func receiveNewPhoto(_ imageURL: URL)
 
}
