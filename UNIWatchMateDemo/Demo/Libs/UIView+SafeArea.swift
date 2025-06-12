//
//  UIView+SafeArea.swift
//  BiuFrameUI
//
//  Created by t_t on 2022/7/27.
//

import UIKit

var isFullScreen: Bool {
    if #available(iOS 13, *) {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return false }
        guard let window = windowScene.windows.first else { return false }
          
      if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
          return true
      }
    }else if #available(iOS 11.0, *) {
        guard let window = UIApplication.shared.windows.first else { return false }
        if window.safeAreaInsets.left > 0 || window.safeAreaInsets.bottom > 0 {
            return true
        }
    }
    return false
}

let kSCREEN_BOUNDS: CGRect = UIScreen.main.bounds
let kSCREEN_WIDTH: CGFloat = kSCREEN_BOUNDS.width
let kSCREEN_HEIGHT: CGFloat = kSCREEN_BOUNDS.height
let kStateBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
let kNavigationBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height + 44
let kBottomSafeHeight = kStateBarHeight > 20 ? 34.0 : 0
let kBottomSafeHeightPlus = kStateBarHeight > 20 ? 34.0 : 20
let kTabBarHeight: CGFloat = isFullScreen ? 34+49 : 49
