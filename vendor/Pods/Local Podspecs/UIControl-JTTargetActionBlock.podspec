Pod::Spec.new do |s|
  s.name         = "UIControl-JTTargetActionBlock"
  s.version      = "0.0.1"
  s.summary      = "Adding blocks support for UIControl target/action mechanism"
  s.homepage     = "https://gist.github.com/jamztang/2205564"
  s.author       = { "Jamz Tang" => "jamz@jamztang.com" }
  s.platform     = :ios
  s.source       = { :git => "git://gist.github.com/2205564.git", :tag => '0.0.1' }
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  s.source_files  = '*.{h,m}'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
end
