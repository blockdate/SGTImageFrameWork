Pod::Spec.new do |s|

  s.name         = "SGTImageFramework"
  s.version      = "0.0.4"
  s.summary      = "This is a private pod sp. provide image picker and viewer function"

  s.description  = <<-DESC
                  ImagePicker ImageViewer .This is a private pod sp. provide image picker and viewer function
                   DESC

  s.homepage     = "https://bitbucket.org/sgtfundation/sgtimageframework"

  s.license      = { :type => "MIT", :file => "LICENSE" }


  s.author             = { "吴磊" => "w.leo.sagittarius@gmail.com" }


  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://bitbucket.org/sgtfundation/sgtimageframework.git", :tag => s.version.to_s }


  s.source_files  = "Source/**/*.{h,m}"

  s.public_header_files = "Source/SGTImagePicker/**/*.h", "Source/ImageBrowser/CorePhotoBroswerVC/**/*.h", "Source/SDWebImage/**/*.h"

  s.resources = 'Source/**/*.{png,pdf,xib,bundle,strings}'

  s.frameworks = "UIKit", "CoreGraphics"


  s.requires_arc = true

  s.dependency 'Masonry', '~> 0.6.3'
  s.dependency 'SDWebImage', '~> 3.7.3'

end
