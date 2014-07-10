class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    # init window with frame of screen bounds
    @win = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    # configure status bar
    UIApplication.sharedApplication.setStatusBarStyle(UIStatusBarStyleLightContent)
    UIApplication.sharedApplication.setStatusBarHidden(false)

    # create uinavigationcontroller witha custom gradient nav bar class
    vc = UINavigationController.alloc.initWithNavigationBarClass(CRGradientNavigationBar, toolbarClass: nil)

    # create a gradient nav bar
    CRGradientNavigationBar.appearance.setBarTintGradientColors(['#FF5E3A'.to_color, '#FF2A68'.to_color]) # pink -> orange
    #CRGradientNavigationBar.appearance.setBarTintGradientColors(['#55EFCB'.to_color, '#5BCAFF'.to_color]) # dark blue -> light blue
    vc.navigationBar.setTranslucent(false)
    vc.navigationBar.titleTextAttributes = {UITextAttributeTextColor => UIColor.whiteColor}

    # init story view controller
    tv = StoryListController.alloc.initWithStyle(UITableViewStylePlain)
    vc.setViewControllers([tv])

    # tints
    @win.tintColor = UIColor.whiteColor
    @win.backgroundColor = UIColor.whiteColor

    # push root view controller
    @win.rootViewController = vc
    @win.rootViewController.wantsFullScreenLayout = true
    @win.makeKeyAndVisible

    # enable system network activity indicator
    AFNetworkActivityIndicatorManager.sharedManager.setEnabled(true)

    # remove back button labels
    UIBarButtonItem.appearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000, -1000), forBarMetrics:UIBarMetricsDefault)

    true
  end
end
