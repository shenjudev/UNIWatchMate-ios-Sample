//
//  AppDelegate.swift
//  UNIWatchMateDemo
//
//  Created by abel on 2025/3/18.
//

import UIKit
import TLOCP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NSLog("App launch.")
        
        
        WMManager.sharedInstance().registerWatchMate(SJWatchFind.sharedInstance())
        
        // 注册日志和设备管理
        // 注册日志级别  SJWatchLib SDK的日志
        WMLog.sharedInstance().register(SJLogInfo.sharedInstance())
        SJLogInfo.sharedInstance().registerLevel("DEBUG")
        SJLogInfo.sharedInstance().registerLevel("INFO")
        
        // 订阅日志
        WMLog.sharedInstance().log.subscribeNext { x in
            if let logString = x {
                let log = String(format: "%@", logString)
                SJSJDeviceDataLogger.logDeviceDataSimplified(log)
            }
        }
        
        // TLOCP库的日志
        TLLogger.shared.addCallback(identifier: "myCallback") { (message, level, fileName, function, line) in
            // 处理日志
            SJSJDeviceData("\n TLOCP  \(message)")
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        // 其他初始化操作...
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
