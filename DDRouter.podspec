#
#  Be sure to run `pod spec lint DDRouter.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DDRouter"
  s.version      = "0.0.1"
  s.summary      = "A Router for modules to communicate each other."
  s.description  = <<-DESC
                     A Router for modules to communicate each other, just do it.
                   DESC
  s.homepage     = "https://github.com/longxdragon/DDRouter"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "longxdragon" => "longxdragon@163.com" }
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/longxdragon/DDRouter.git", :tag => "#{s.version}" }
  s.source_files  = "DDRouter/DDRouter/*.{h,m}"
  s.module_name   = 'DDRouter'

end
