#
# Be sure to run `pod lib lint CNLiveGifFace.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CNLiveGifFace'
  s.version          = '0.0.1'
  s.summary          = 'GIF表情.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://bj.gitlab.cnlive.com/ios-team/CNLiveGifFace'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '153993236@qq.com' => 'zhangxiaowen@cnlive.com' }
  s.source           = { :git => 'http://bj.gitlab.cnlive.com/ios-team/CNLiveGifFace.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CNLiveGifFace/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CNLiveGifFace' => ['CNLiveGifFace/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'Masonry'
  s.dependency 'MJRefresh'
  s.dependency 'QMUIKit'
  s.dependency 'CNLiveBaseKit'
  s.dependency 'CNLiveUserManagement'
  s.dependency 'MJExtension'
  s.dependency 'CNLiveCommonClass'
  s.dependency 'CNLiveCustomUI'
  s.dependency 'WebViewJavascriptBridge'
  s.dependency 'SSZipArchive'
  s.dependency 'CNLiveCommonCategory'
  s.dependency 'CNLiveCommonClass'
  s.dependency 'IMBaseSDK'
  
end
