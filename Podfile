source 'https://github.com/CocoaPods/Specs'
platform :ios, '8.0'

workspace 'SGTImageFramework'
project 'SGTImageFramework.xcodeproj'
project 'Demo/Demo.xcodeproj'

target 'SGTImageFramework' do
    project 'SGTImageFramework.xcodeproj'
    platform :ios, '8.0'
    pod 'ReactiveObjC'
    pod 'Masonry'
    pod 'SDWebImage'
    pod 'DACircularProgress'
    pod 'pop'
    pod 'MBProgressHUD'
end

 target 'Demo' do
     project 'Demo/Demo.xcodeproj'
     platform :ios, '8.0'
     pod 'Masonry'
     pod 'SDWebImage'
     pod 'DACircularProgress'
     pod 'MBProgressHUD'
     pod 'pop'
     pod 'Reveal-iOS-SDK', :configurations => ['Debug']
 end
