platform :ios, '15.0'
use_frameworks!

install! 'cocoapods',
            :warn_for_unused_master_specs_repo => false

target 'Sample' do
    pod 'SwiftLint'
    pod 'R.swift'
        
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'Moya/RxSwift'
    pod 'Nuke'
    
    target 'SampleTests' do
        inherit! :search_paths
    end
end


post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
    end
end
