#
# Be sure to run `pod lib lint BCFaceSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BCFaceSDK'
  s.version          = '0.1.5'
  s.summary          = 'BCFaceSDK是一个人脸识别类库'
  s.homepage         = 'https://github.com/kingly09/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kingly09' => 'libintm@163.com' }
  s.source           = { :git => 'https://github.com/kingly09/KYFaceDetector.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.source_files = 'BCFaceSDK/Classes/**/*','BCFaceSDK/Assets/FaceSDK/**/*.h'
  
   s.resource_bundles = {
     'BCFaceSDK' => ['BCFaceSDK/Assets/**/*.{png,jpg}']
   }

  s.public_header_files = 'BCFaceSDK/Classes/public/*.h'
  
  s.frameworks = 'UIKit','Accelerate','Foundation','SystemConfiguration','CFNetwork','Security','CoreMedia','CoreAudio','AVFoundation','MobileCoreServices'
                 
  s.ios.vendored_frameworks = 'BCFaceSDKDemo/BCFaceSDKDemo/SDK/**/*.framework'
  #s.ios.vendored_libraries  = 'BCFaceSDK/Assets/**/*.a'
                 
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'GTMBase64', '~> 1.0.0'
  
end
