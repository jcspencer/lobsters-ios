class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @win = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleLightContent)
    UIApplication.sharedApplication.setStatusBarHidden(false)

    vc = UINavigationController.alloc.initWithNavigationBarClass(CRGradientNavigationBar, toolbarClass: nil)

    CRGradientNavigationBar.appearance.setBarTintGradientColors(['#FF5E3A'.to_color, '#FF2A68'.to_color])
    #CRGradientNavigationBar.appearance.setBarTintGradientColors(['#55EFCB'.to_color, '#5BCAFF'.to_color])
    vc.navigationBar.setTranslucent(false)
    vc.navigationBar.titleTextAttributes = {UITextAttributeTextColor => UIColor.whiteColor}

    tv = StoryListController.alloc.initWithStyle(UITableViewStylePlain)
    vc.setViewControllers([tv])

    @win.tintColor = UIColor.whiteColor
    @win.backgroundColor = UIColor.whiteColor

    @win.rootViewController = vc
    @win.rootViewController.wantsFullScreenLayout = true
    @win.makeKeyAndVisible

    AFNetworkActivityIndicatorManager.sharedManager.setEnabled(true)

    UIBarButtonItem.appearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000), forBarMetrics:UIBarMetricsDefault)

    true
  end
end
