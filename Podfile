source 'https://github.com/CocoaPods/Specs'
platform :ios, '8.0'
inhibit_all_warnings!

workspace 'SGTImageFramework'
project 'SGTImageFramework.xcodeproj'
project 'Demo/Demo.xcodeproj'

target 'SGTImageFramework' do
    project 'SGTImageFramework.xcodeproj'
    platform :ios, '8.0'
    pod 'ReactiveCocoa', '~> 2.5'
    pod 'Masonry', '~> 0.6.3'
    pod 'SDWebImage', '~> 3.7.3'
end

 target 'Demo' do
     project 'Demo/Demo.xcodeproj'
     platform :ios, '8.0'
     pod 'ReactiveCocoa', '~> 2.5'
     pod 'Masonry', '~> 0.6.3'
     pod 'SDWebImage', '~> 3.7.3'
 end