#
# Be sure to run `pod lib lint SendAnywhereSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SendAnywhereSDK'
  s.version          = '4.0.0'
  s.summary          = 'SendAnywhereSDK is a kit for file transferring.'
  s.description      = '* SendAnywhereSDK is a kit for file transferring. *'

  s.homepage         = 'https://send-anywhere.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'doyoung park' => 'do@estmob.com' }
  s.source           = { :git => 'https://github.com/dustmob/SendAnywhereSDK.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/send_anywhere'

  s.ios.deployment_target = '8.0'

  # s.source_files = 'SendAnywhereSDK/Classes/**/*'
  s.ios.vendored_frameworks = 'SendAnywhereSDK/Frameworks/SendAnywhereSDK.framework'
end
