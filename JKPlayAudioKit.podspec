#
# Be sure to run `pod lib lint JKPlayAudioKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JKPlayAudioKit'
  s.version          = '0.0.2'
  s.summary          = 'OC的播放器'
  s.description      = '这是一个OC封装的音频播放器'

  s.homepage         = 'https://github.com/JoanKing/JKPlayAudioKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'JoanKing' => 'jkironman@163.com' }
  s.source           = { :git => 'https://github.com/JoanKing/JKPlayAudioKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'JKPlayAudioKit/Classes/**/*'
  
end
