platform :ios, '12.0'
#ENV['SWIFT_VERSION'] = '5.0'

workspace 'UNIWatchMate.xcworkspace'

target 'UNIWatchMateDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  project './UNIWatchMateDemo.xcodeproj'
   
   use_frameworks!
   
   pod 'YYCategories','1.0.4'
   pod "ReactiveObjC",'3.1.1'
   # Pods for UNIWatchMateDemo
   
   pod 'RxSwift' , '6.8.0'
   pod 'RxCocoa' , '6.8.0'
   pod 'PromiseKit','8.1.1'
   pod 'HandyJSON', '5.0.0'
   pod 'SwiftyJSON','5.0.1'
   # Pods for UNIWatchMateDemo
  
  pod 'LBXScan','2.5.1'
  pod 'MBProgressHUD','1.2.0'
  pod 'Toast','4.0.0'
  pod 'SVProgressHUD','2.2.5'
#  pod 'QuickTraceiOSLogger','2.0.7'
  pod 'HDWindowLogger', :path=> './localLib/HDWindowLogger'
  pod 'LSTPopView',"0.3.10"
    pod 'ZYImagePicker', '~> 0.1.2'
  pod 'SnapKit',:git => 'https://github.com/SnapKit/SnapKit.git'
  #swift extension
  pod 'SwifterSwift', '5.2.0'
  #Localized extension
  pod 'Localize-Swift', '~> 3.2.0'
  pod 'MJExtension'
  pod 'SWCompression/TAR'
  pod 'YYText'
  pod 'AFNetworking', '~> 4.0'
  pod 'OpenSSL-Universal'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      if config.name == "Debug"
        config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = []

      end
    end
  end
#  installer.aggregate_targets.each do |target|
#    target.xcconfigs.each do |variant, xcconfig|
#      xcconfig_path = target.client_root + target.xcconfig_relative_path(variant)
#      IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
#    end
#  end
#  
#  installer.pods_project.targets.each do |target|
#    target.build_configurations.each do |config|
#      if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
#        xcconfig_path = config.base_configuration_reference.real_path
#        IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
#      end
#    end
#  end
 
end

