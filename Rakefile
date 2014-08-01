# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bubble-wrap/core'
require 'time'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Lobsters'

  app.version = '1.1'
  app.deployment_target = '7.0'
  app.identifier = 'com.jamess237.lobsters'
  app.codesign_certificate = "iPhone Distribution: James Spencer"
  app.provisioning_profile = "/Users/James/Library/MobileDevice/Provisioning\ Profiles/F78F85D4-6197-4C65-BE19-F025771710B0.mobileprovision"
  app.prerendered_icon = true

  app.vendor_project('vendor/InfiniteScroll', :static)

  app.pods do
    pod 'YLMoment'
    pod 'REMenu'
    pod 'MBProgressHUD'
    pod 'SpinKit'
    pod 'NZCircularImageView'
    pod 'CRGradientNavigationBar'
    pod 'SVWebViewController', :git => 'https://github.com/shahruz/SVWebViewController.git', :commit => 'ffef735190'
    pod 'BlocksKit'
    pod 'UIControl-JTTargetActionBlock', :git => 'git://gist.github.com/2205564.git'
    pod 'SIAlertView'
  end

  app.icons = ["Icon.png", "Icon-60@2x.png"]
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false

  app.device_family = [:iphone]
end
