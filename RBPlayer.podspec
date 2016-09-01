#
# Be sure to run `pod lib lint RBPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RBPlayer'
  s.version          = '0.1.2'
  s.summary          = 'customizable Video Player, based on AVPlayer.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
* Fully customizable UI
* No view-level restrictions (have it any size and position you would like!)
* Supports HTTP Live Streaming protocol
* Orientation change support (even when orientation lock is enabled)
                       DESC

  s.homepage         = 'https://github.com/itribs/RBPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ribs' => '234126357@qq.com' }
  s.source           = { :git => 'https://github.com/itribs/RBPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'http://weibo.com/2839148394'

  s.ios.deployment_target = '7.0'

  s.source_files = 'RBPlayer/Classes/**/*'
  
  s.resource_bundles = {
    'RBPlayer' => ['RBPlayer/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
