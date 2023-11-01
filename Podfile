platform :ios, '12.0'
ENV['SWIFT_VERSION'] = '5.0'


target 'UNIWatchMateDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  project './UNIWatchMateDemo.xcodeproj'
  workspace 'UNIWatchMate.xcworkspace'
  use_frameworks!
  
  pod 'YYCategories','1.0.4'
  pod "ReactiveObjC",'3.1.1'
  # Pods for UNIWatchMateDemo
  
  pod 'RxSwift','6.6.0'
  pod 'RxCocoa','6.6.0'
  pod 'PromiseKit','8.1.1'
  pod 'HandyJSON','5.0.2'
  pod 'SwiftyJSON','5.0.1'
  # Pods for UNIWatchMateDemo
  
  pod 'LBXScan','2.5.1'
  pod 'MBProgressHUD','1.2.0'
  pod 'Toast','4.0.0'
  pod 'SVProgressHUD','2.2.5'
  pod 'QuickTraceiOSLogger','2.0.7'
  pod 'HDWindowLogger', :path=> './localLib/HDWindowLogger'
  pod 'LSTPopView',"0.3.10"
  
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
end
