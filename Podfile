source 'https://github.com/CocoaPods/Specs'
platform :ios, '8.0'
inhibit_all_warnings!

workspace 'SGTImageFramework'
xcodeproj 'SGTImageFramework.xcodeproj'
xcodeproj 'Demo/Demo.xcodeproj'

target 'SGTImageFramework' do
    xcodeproj 'SGTImageFramework.xcodeproj'
    platform :ios, '8.0'
    pod 'ReactiveCocoa', '~> 2.5'
    pod 'Masonry', '~> 0.6.3'
    pod 'SDWebImage', '~> 3.7.3'
end

target 'Demo' do
    xcodeproj 'Demo/Demo.xcodeproj'
    platform :ios, '7.0'
    
    pod 'SGTImageFramework', :path => '../SGTImageFramework'
end