//
//  USTheme.swift
//  Biu2us
//
//  Created by t_t on 2022/10/12.
//

import UIKit

fileprivate extension String {
    var image: UIImage? {
        UIImage(named: "\(USTheme.share.style.name)_\(self)")
    }
    var imageRTL: UIImage? {
        UIImage(named: "\(USTheme.share.style.name)_\(self)_RTL")
    }
}

class USTheme {
    enum Style {
        case `default`
        
        var name: String {
            switch self {
            case .default: return "df"
            }
        }
    }
    enum Image {
        case launchScreen
        case bg_top
        case icon_app
        case icon_tf_email
        case icon_tf_pas
        case icon_tf_user
        case icon_tf_code
        case btn_tf_ming
        case btn_tf_mi
        case btn_tf_clear
        case btn_sel
        case btn_sel_dis
        case navi_back
        case user_def
        case scaned_show
        case icon_headset
        case icon_watch
        case icon_add
        case icon_sel
        case icon_dsel
        case icon_close
        case ill_watch
        case bg_drawer
        case icon_local
        case icon_app_update
        case icon_about
        case icon_arrow_right
        case icon_logout
        case icon_local_sel
        case icon_logo_yuan
        case watch_about
        case watch_display
        case watch_mp3
        case watch_notify
        case watch_pass
        case watch_power_100
        case watch_power_80
        case watch_power_60
        case watch_power_40
        case watch_power_20
        case watch_power_ing
        case watch_time
        case watch_upgrade
        case watch_tag
        case watch_tab_health
        case watch_tab_set
        case watch_tab_dial
        case watch_tab_health_sel
        case watch_tab_set_sel
        case watch_tab_dial_sel
        case watch_jiankang_info
        case watch_birthday
        case watch_close
        case watch_sel
        case watch_disel
        case watch_dist
        case watch_gender
        case watch_heat
        case watch_height
        case watch_men_sel
        case watch_men
        case watch_steps
        case watch_weight
        case watch_woman_sel
        case watch_woman
        case watch_about_bg
        case watch_dial_df
        case watch_record
        case watch_record_empty
        case watch_ic_heartRate
        case watch_ic_dist
        case watch_ic_chart
        case watch_ic_calories
        case watch_ic_steps
        case watch_ic_refresh
        case watch_ble_off
        case watch_slide
        case watch_empty_devices
        case device_curr
        case watch_rate_range
        case watch_upgrade_error
        case watch_upgrade_image
        case watch_download_error
        case watch_successful
        case watch_failure
        case watch_ic_complete
        case watch_binding
        case watch_bind_error
        case watch_ble_unauth
        case device_add
        case device_more
        case watch_tab_mine_sel
        case watch_tab_mine
        case ble_off
        case ble_off_cell
        case ble_off_dis
        case watch_audio
        case watch_send_file
        case loading_devices
        case loading_devices_error
        
        var name: String {
            switch self {
            case .launchScreen: return "launchScreen"
            case .bg_top: return "bg_top"
            case .icon_app: return "icon_app"
            case .icon_tf_email: return "ic_tf_email"
            case .icon_tf_pas: return "ic_tf_pas"
            case .icon_tf_user: return "ic_tf_user"
            case .icon_tf_code: return "ic_tf_code"
            case .btn_tf_ming: return "btn_tf_ming"
            case .btn_tf_mi: return "btn_tf_mi"
            case .btn_tf_clear: return "btn_tf_clear"
            case .btn_sel: return "btn_sel"
            case .btn_sel_dis: return "btn_sel_dis"
            case .navi_back: return "navi_back"
            case .user_def: return "user_def"
            case .scaned_show: return "scaned_show"
            case .icon_headset: return "icon_headset"
            case .icon_watch: return "icon_watch"
            case .icon_add: return "icon_add"
            case .icon_sel: return "icon_sel"
            case .icon_dsel: return "icon_dsel"
            case .icon_close: return "icon_close"
            case .ill_watch: return "ill_watch"
            case .bg_drawer: return "bg_drawer"
            case .icon_local: return "icon_local"
            case .icon_app_update: return "icon_app_update"
            case .icon_about: return "icon_about"
            case .icon_arrow_right: return "icon_arrow_right"
            case .icon_logout: return "icon_logout"
            case .icon_local_sel: return "icon_local_sel"
            case .icon_logo_yuan: return "icon_logo_yuan"
            case .watch_about: return "watch_about"
            case .watch_display: return "watch_display"
            case .watch_mp3: return "watch_mp3"
            case .watch_notify: return "watch_notify"
            case .watch_pass: return "watch_pass"
            case .watch_power_100: return "watch_power_100"
            case .watch_power_80: return "watch_power_80"
            case .watch_power_60: return "watch_power_60"
            case .watch_power_40: return "watch_power_40"
            case .watch_power_20: return "watch_power_20"
            case .watch_power_ing: return "watch_power_ing"
            case .watch_tag: return "watch_tag"
            case .watch_time: return "watch_time"
            case .watch_upgrade: return "watch_upgrade"
            case .watch_tab_health: return "watch_tab_health"
            case .watch_tab_set: return "watch_tab_set"
            case .watch_tab_dial: return "watch_tab_dial"
            case .watch_tab_set_sel: return "watch_tab_set_sel"
            case .watch_tab_health_sel: return "watch_tab_health_sel"
            case .watch_tab_dial_sel: return "watch_tab_dial_sel"
            case .watch_jiankang_info: return "watch_jiankang_info"
            case .watch_birthday: return "watch_birthday"
            case .watch_close: return "watch_close"
            case .watch_sel: return "watch_sel"
            case .watch_disel: return "watch_disel"
            case .watch_dist: return "watch_dist"
            case .watch_gender: return "watch_gender"
            case .watch_heat: return "watch_heat"
            case .watch_height: return "watch_height"
            case .watch_men_sel: return "watch_men_sel"
            case .watch_men: return "watch_men"
            case .watch_steps: return "watch_steps"
            case .watch_weight: return "watch_weight"
            case .watch_woman_sel: return "watch_woman_sel"
            case .watch_woman: return "watch_woman"
            case .watch_about_bg: return "watch_about_bg"
            case .watch_dial_df: return "watch_dial_df"
            case .watch_record: return "watch_record"
            case .watch_record_empty: return "watch_record_empty"
            case .watch_ic_heartRate: return "watch_ic_heartRate"
            case .watch_ic_dist: return "watch_ic_dist"
            case .watch_ic_chart: return "watch_ic_chart"
            case .watch_ic_calories: return "watch_ic_calories"
            case .watch_ic_steps: return "watch_ic_steps"
            case .watch_ic_refresh: return "watch_ic_refresh"
            case .watch_ble_off: return "watch_ble_off"
            case .watch_slide: return "watch_slide"
            case .watch_empty_devices: return "watch_empty_devices"
            case .device_curr: return "device_curr"
            case .watch_rate_range: return "watch_rate_range"
            case .watch_upgrade_error: return "watch_upgrade_error"
            case .watch_upgrade_image: return "watch_upgrade_image"
            case .watch_download_error: return "watch_download_error"
            case .watch_successful: return "watch_successful"
            case .watch_failure: return "watch_failure"
            case .watch_ic_complete: return "watch_ic_complete"
            case .watch_binding: return "watch_binding"
            case .watch_bind_error: return "watch_bind_error"
            case .watch_ble_unauth: return "watch_ble_unauth"
            case .device_add: return "device_add"
            case .device_more: return "device_more"
            case .watch_tab_mine_sel: return "watch_tab_mine_sel"
            case .watch_tab_mine: return "watch_tab_mine"
            case .ble_off: return "ble_off"
            case .ble_off_cell: return "ble_off_cell"
            case .ble_off_dis: return "ble_off_dis"
            case .watch_audio: return "watch_audio"
            case .watch_send_file: return "watch_send_file"
            case .loading_devices: return "loading_devices"
            case .loading_devices_error: return "loading_devices_error"
            }
        }
    }
    
    static let share = USTheme()
    var style: Style = .default
}

extension UIImage {
    class func image(_ style: USTheme.Image) -> UIImage? {
        return style.name.image
    }
  
    class func image(_ style: USTheme.Image,_ RTL:Bool) -> UIImage? {
        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft && RTL == true{
            return style.name.imageRTL
        }
        return style.name.image
    }
}
public extension UIColor {
    class func hex(_ hexString: String, alpha: CGFloat = 1) -> UIColor {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red = CGFloat(r)/255
        let green = CGFloat(g)/255
        let blue = CGFloat(b)/255
        
        return .init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension UIFont {
    class func pingFangSC_Bold(_ size: CGFloat) -> UIFont {
        //return .init(name: "HarmonyOS_Sans_SC_Bold", size: size)!
        return .systemFont(ofSize: size, weight: .bold)
    }
    class func pingFangSC_Semibold(_ size: CGFloat) -> UIFont {
//        return .init(name: "HarmonyOS_Sans_SC_Bold", size: size)!
        return .systemFont(ofSize: size, weight: .semibold)
    }
    class func pingFangSC_Light(_ size: CGFloat) -> UIFont {
//        return .init(name: "HarmonyOS_Sans_SC_Light", size: size)!
        return .systemFont(ofSize: size, weight: .light)
    }
    class func pingFangSC_Medium(_ size: CGFloat) -> UIFont {
//        return .init(name: "HarmonyOS_Sans_SC_Medium", size: size)!
        return .systemFont(ofSize: size, weight: .medium)
    }
    class func pingFangSC_Regular(_ size: CGFloat) -> UIFont {
//        return .init(name: "HarmonyOS_Sans_SC", size: size)!
        return .systemFont(ofSize: size, weight: .regular)
    }
    /// pingFangSC_Semibold(30)
    class var titleH1: UIFont {
        return pingFangSC_Semibold(30)
    }
    /// pingFangSC_Semibold(24)
    class var titleH1_1: UIFont {
        return pingFangSC_Regular(28)
    }
    /// pingFangSC_Semibold(24)
    class var titleH1_5: UIFont {
        return pingFangSC_Semibold(24)
    }
    /// pingFangSC_Semibold(18)
    class var titleH2: UIFont {
        return pingFangSC_Semibold(18)
    }
    class var titleL2: UIFont {
        return pingFangSC_Light(18)
    }
    /// pingFangSC_Light(18)
    class var titleH3: UIFont {
        return pingFangSC_Light(20)
    }
    /// pingFangSC_Light(14)
    class var titleH5: UIFont {
        return pingFangSC_Light(16)
    }
    /// pingFangSC_Light(16)
    class var tfPlaceholder: UIFont {
        return pingFangSC_Light(16)
    }
    /// pingFangSC_Medium(16)
    class var tfText: UIFont {
        return pingFangSC_Medium(16)
    }
    /// pingFangSC_Light(16)
    class var homeEmail: UIFont {
        return pingFangSC_Light(16)
    }
}

