//
//  TSDeviceDialTools.swift
//  UNIWatchMateDemo
//
//  Created by t_t on 2024/2/29.
//

import UIKit

class TSDeviceDialTools {
    static var shared = TSDeviceDialTools()
    private init() { }
}
// MARK: The dial requires configuration parameters
extension TSDeviceDialTools{
    /// Create the dial size of the dial
    /// - Returns: Dial size size
    func getDialSize() -> CGSize {
        return CGSize(width: 320, height: 386)
    }
    
    /// Create dial generation rules for the dial
    /// - Returns: Generation rule
    func getDialRule() -> Bool {
        return false
    }
    
    /// Gets the style of the authoring dial
    /// - Returns: Dial style for device type
    func getDialTimeStyles() -> [UIImage] {
        return [UIImage(named: "ic_dail_time_top_left") ?? UIImage(),
                UIImage(named: "ic_dail_time_bottom_left") ?? UIImage(),
                UIImage(named: "ic_dail_time_top_right") ?? UIImage(),
                UIImage(named: "ic_dail_time_bottom_right") ?? UIImage()]
    }
   
    /// Gets the color of the creation dial
    /// - Returns: Dial color for device type
    func getDialTimeColors() -> [String] {
        return ["#FFFFFF", "#333333", "#F7B500", "#44D7B6", "#32C5FF", ""]
    }
    
    /// Whether the current dial is a custom dial ID
    private func getCustomizeDailids() -> [String] {
        return []
    }
    
    /// Whether the current dial is a custom bin file address
    private func getCustomizeBinPath() -> [String] {
        return []
    }
    // Local dial name
    private func getLocalDialNames() -> [String] {
        return ["", "", ""]
    }
    // Local dial ICon
    private func getLocalDialIcons() -> [String] {
        return ["ic_watch_01_OSW820", "ic_watch_02_OSW820", "ic_watch_03_OSW820", "ic_watch_04_OSW820", "ic_watch_05_OSW820"]
    }
    
    /// Create the rounded corners of the dial
    /// - Returns:Fillet size
    func getcornerRadii() -> CGFloat {
        return 25
    }
}

// MARK: Get the device's dial information
extension TSDeviceDialTools {
    
    public func getDialBinPath(idx:Int) -> String {
        let allBins = getCustomizeBinPath()
        if idx < allBins.count && idx >= 0{
            return allBins[idx]
        }
        return ""
    }
    
    public func getDialId(idx:Int) -> String {
        let allIDs = getCustomizeDailids()
        if idx < allIDs.count && idx >= 0{
            return allIDs[idx]
        }
        return ""
    }
    
  


    
    
}

// MARK:
extension TSDeviceDialTools {
    
    private func getLocalDailName(idx:Int) -> String{
        let allName = self.getLocalDialNames()
        if idx < allName.count && idx >= 0 {
            return allName[idx]
        }
        return ""
    }
    
    private func getLocalDailIcon(idx:Int) -> String{
        let allIcons = self.getLocalDialIcons()
        if idx < allIcons.count && idx >= 0 {
            return allIcons[idx]
        }
        return ""
    }
}

// MARK: 创作表盘
extension TSDeviceDialTools {
    
    /// 将自定义表盘文件存入本地
    /// - Parameters:
    ///   - picture: 选中的相册图片
    ///   - textImage: 选中的表盘样式icon
    func saveCustomDialImage(_ picture : UIImage?, textImage : UIImage?, dialId: String? = nil){
        guard let bgImage = picture, let textImg = textImage else {
            return
        }
//        let img = ZHDWatchFaceTool.addImageBG(bgImage, with: textImg, andImaX: 0, imaY: 0)
//        
//        if let imageData = img.jpegData(compressionQuality: 1) as NSData? {
//            let fullPath = TSDeviceDialTools.getDailFilePath()
//            // 检查文件夹是否存在，不存在创建
//            if FileManager.default.isExecutableFile(atPath: fullPath) == false {
//                do {
//                    try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
//                } catch let error {
//                    ZHLog(error)
//                }
//            }
//            // 拼接文件地址
//            let dialPath = TSDeviceDialTools.getDailFullFileName(dialId: dialId)
//            do {
//                try FileManager.default.removeItem(atPath: dialPath)
//            } catch let error {
//                ZHLog(error)
//            }
//            //在写入文件
//            imageData.write(toFile: dialPath, atomically: true)
//        }
    }
    
    /// 将自定义表盘文件存入本地
    /// - Parameters:
    ///   - picture: 预览图
    func saveCustomDialImage(_ picture : UIImage?){
        guard let bgImage = picture else {
            return
        }
        if let imageData = bgImage.jpegData(compressionQuality: 1) as NSData? {
            let fullPath = TSDeviceDialTools.getDailFilePath()
            // 检查文件夹是否存在，不存在创建
            if FileManager.default.isExecutableFile(atPath: fullPath) == false {
                do {
                    try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
//                    DDPrint(error)
                }
            }
            // 拼接文件地址
            let dialPath = TSDeviceDialTools.getDailFullFileName()
            do {
                try FileManager.default.removeItem(atPath: dialPath)
            } catch let error {
//                DDPrint(error)
            }
            //在写入文件
            imageData.write(toFile: dialPath, atomically: true)
        }
    }
    
    /// 当前表盘是否是自定义表盘
    /// - Parameter dailid: 表盘id
    /// - Returns: true 是
    private func isCustomizeDail(dailid :String?) -> Bool {
        let allDailids = self.getCustomizeDailids()
        return allDailids.contains { dailid?.contains($0) == true }
    }
}

// MARK: 表盘文件
extension TSDeviceDialTools {
    // 创建表盘文件夹
    func createDailFolder() {
        let fullPath = TSDeviceDialTools.getDailFilePath()
        // 检查文件夹是否存在，不存在创建
        if FileManager.default.isExecutableFile(atPath: fullPath) == false {
            do {
                try FileManager.default.createDirectory(atPath: fullPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                ZHLog(error)
            }
        }
    }
    
    /// 获取表盘文件夹路径
    /// - Returns: 文件夹路径
    static func getDailFilePath() -> String {
        return NSHomeDirectory().appending("/Documents/TSDails/")
    }
    
   
    
    /// 获取表盘名称
    /// - Returns:表盘名称
    static func getDailFullFileName(dialId: String? = nil) -> String {
//        return TSDeviceDialTools.getDailFilePath().appending(TSDeviceDialTools.getDailFileName(dialId: dialId))
        return TSDeviceDialTools.getDailFilePath().appending(dialId ?? "")
    }
}
