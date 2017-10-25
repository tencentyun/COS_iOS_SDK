Pod::Spec.new do |s|
  s.name         = "QCloudCOSV4"
  s.version      = "1.5.2"
  s.summary      = "腾讯云对象存储服务COS，iOS-SDK"
  s.description  = <<-DESC
                  腾讯云对象存储服务COS，iOS-SDK。提供文件上传等基本操作。
                  DESC

  s.homepage     = "https://github.com/studentdeng/ShareCenterExample"
  s.license      = 'MIT'
  s.author       = { "curer" => "baronjia@tencent.com" }
  s.platform     = :ios, '7.0'
  s.source       = { :git => "https://github.com/tencentyun/COS_iOS_SDK.git", :tag => s.version.to_s }
  s.source_files  = 'coslib/**/*.{h,m}'
  s.vendored_libraries = 'coslib/libCOSClient.a'
  s.frameworks = "CoreTelephony", "Foundation", "SystemConfiguration"
end
