Pod::Spec.new do |s|
  s.name         = "BayMaxProtector"
  s.version      = "2.3"
  s.summary      = "Crash protector--Take care of your application like BayMax"
  s.homepage     = "https://github.com/sunday1990/BayMaxProtector"
  s.license      = "MIT"
  s.author             = { "ccSunday" => "935143023@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/sunday1990/BayMaxProtector.git", :tag => "v2.3" }
  s.social_media_url   = "https://github.com/sunday1990/BayMaxProtector"
  s.source_files  = 'Class/**/*.{h,m}'
  s.requires_arc = true
  s.framework  = "UIKit"
end
