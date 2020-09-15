Pod::Spec.new do |s|
s.name = 'Framework'
s.version = '1.0.0'
s.author = 'x'
s.license = { :type => 'Copyright', :text => 'Copyright 2006-2020 x.com Inc. All rights reserved.' }
s.homepage = 'x.com'
s.source = { :git =>'https://github.com/lijingcheng/Framework.git' }
s.summary = '框架.'
#s.static_framework = true
s.swift_version = '5.2'
s.ios.deployment_target = '10.0'
s.module_map = 'Framework/Framework.modulemap'
s.source_files = 'Framework/Framework-Swift.h', 'Framework/Class/*.swift'

s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.dependency 'Alamofire', '5.2.1'

end
