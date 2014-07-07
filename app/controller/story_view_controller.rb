class StoryListController < UITableViewController
  def viewDidLoad
    set_reloader
    set_dropdown_menu
    infinite_scroll
    self.tableView.setSeparatorStyle(UITableViewCellSeparatorStyleNone)

    @client = AFMotion::Client.build("https://lobste.rs/") do
      header "Accept", "application/json"
      response_serializer :json
    end

    @page = 1
    @endpoint = "hottest.json"
    @stories = []
    view.dataSource = view.delegate = self

    hud = create_hud "Loading..."
    refresh(@endpoint) do |data|
      @stories = data
      view.reloadData
      hud.hide(true)
    end
  end

  def viewWillAppear(animated)
    self.title = "Lobsters - Hottest"
    navigationController.setNavigationBarHidden(false, animated:true)
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    true
  end

  # add infinite scroll to the table
  def infinite_scroll
    @infinite_scroll_handler = lambda do
      @page += 1
      refresh(@endpoint) do |data|
        @stories = @stories.concat data
        view.reloadData
        self.tableView.finishInfiniteScroll
      end
    end
    self.tableView.addInfiniteScrollWithHandler(@infinite_scroll_handler)
  end

  # create a loader hud
  def create_hud(msg)
    spinner = RTSpinKitView.alloc.initWithStyle(RTSpinKitViewStyleWanderingCubes, color: UIColor.whiteColor)
    hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    hud.square = true
    hud.mode = MBProgressHUDModeCustomView
    hud.customView = spinner
    #hud.labelText = "Pulling Stories"
    spinner.startAnimating

    hud
  end

  # add pull to refresh
  def set_reloader
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.tintColor = UIColor.grayColor
    @refreshControl.addTarget self, action: :pull_refresh, forControlEvents:UIControlEventValueChanged
    self.refreshControl = @refreshControl
  end

  # create the endpoint selection menu
  def set_dropdown_menu
    @set_hottest = lambda do |i|
      @endpoint = "hottest.json"
      @page = 1
      hud = create_hud "Loading..."
      refresh(@endpoint) do |data|
        @stories = data
        view.reloadData
        self.title = "Lobsters - Hottest"
        hud.hide(true)
      end
    end
    @set_newest = lambda do |i|
      @endpoint = "newest.json"
      @page = 1
      hud = create_hud "Loading..."
      refresh(@endpoint) do |data|
        @stories = data
        view.reloadData
        self.title = "Lobsters - Newest"
        hud.hide(true)
      end
    end

    hottest = REMenuItem.alloc.initWithTitle("Hottest", subtitle: nil, image: nil, highlightedImage: nil, action: @set_hottest)
    newest = REMenuItem.alloc.initWithTitle("Newest", subtitle: nil, image: nil, highlightedImage: nil, action: @set_newest)
    items = [hottest, newest]

    @menu = REMenu.alloc.initWithItems(items)

    down_arrow = UIImage.imageNamed("down")
    button_view = UIButton.buttonWithType(UIButtonTypeCustom)
    button_view.bounds = CGRectMake(0, 0, 32, 32)
    button_view.setImage(down_arrow, forState:UIControlStateNormal)
    button_view.addTarget(self, action: :choose_endpoint, forControlEvents:UIControlEventTouchUpInside)
    arrow = UIBarButtonItem.alloc.initWithCustomView(button_view)
    self.navigationItem.rightBarButtonItem = arrow
  end

  # dropdown the endpoint menu
  def choose_endpoint
    if @menu.isOpen
      return @menu.close
    end
    @menu.showFromNavigationController(self.navigationController)
  end

  # trigger pull to refresh
  def pull_refresh(refresh = true)
    refresh(@endpoint) do |data|
      @stories = data
      view.reloadData
      @refreshControl.endRefreshing
    end
  end

  # alert the user to errors
  def show_error(msg)
    #alert = UIAlertView.alloc.initWithTitle("Error", message: msg, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
    alert = SIAlertView.alloc.initWithTitle("Oh noes!", andMessage: msg)
    alert.transitionStyle = SIAlertViewTransitionStyleBounce

    alert.addButtonWithTitle("OK", type: SIAlertViewButtonTypeDestructive, handler: nil)
    alert.addButtonWithTitle("Reload", type: SIAlertViewButtonTypeDefault, handler: lambda do |al|
      hud = create_hud "Loading..."
      refresh(@endpoint) do |data|
        @stories = data
        view.reloadData
        hud.hide(true)
      end
    end)
    alert.show
  end

  # reload the table view
  def refresh(endpoint, &block)
    begin
      @cb = block
      @client.get(endpoint, page: @page) do |result|
        if result.success?
          data = result.object.map { |i| LobstersStory.new i }
          @cb.call data
        else
          show_error result.error.localizedDescription
          @cb.call []
        end
      end
    rescue Exception => msg
      show_error msg
    end
  end

  def blank_image(size, color)
    UIGraphicsBeginImageContext(size);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    outputImage
  end

  def truncate(t, length = 20, omis = "...")
    text = t.dup
    if text.length > length
      text = text[0...length].strip + omis
    end

    text
  end

  # Table View
  def tableView(tv, numberOfRowsInSection:section)
    @stories.size
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    cid = "PostCell"
    cell = tv.dequeueReusableCellWithIdentifier(cid) ||
           UITableViewCell.alloc.initWithStyle(
                UITableViewCellStyleSubtitle,
                reuseIdentifier:cid)

    p = @stories[indexPath.row]

    image = NZCircularImageView.alloc.initWithFrame(CGRectMake(16, 32, 64, 64))
    url = NSURL.URLWithString(p.author.avatar)
    image.setImageWithResizeURL(url.absoluteString)
    cell.addSubview(image)

    cell.imageView.image = blank_image(CGSize.new(64, 64), UIColor.clearColor)

    title = p.title
    title = truncate(p.title, 40) unless Device.ipad?
    cell.textLabel.text = title
    cell.detailTextLabel.text = p.generate_description
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    cell.textLabel.numberOfLines = 0
    cell.detailTextLabel.numberOfLines = 0

    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    s = @stories[indexPath.row]

    url = s.url.absoluteString
    @sid = s.sid
    modal = SVWebViewController.alloc.initWithAddress url

    down_arrow = UIImage.imageNamed("note")
    button_view = UIButton.buttonWithType(UIButtonTypeCustom)
    button_view.bounds = CGRectMake(0, 0, 32, 32) unless Device.ipad?
    button_view.bounds = CGRectMake(0, modal.view.bounds.size.width / 2, 48, 48) if Device.ipad?
    button_view.backgroundColor = UIColor.blackColor if Device.ipad?
    button_view.setImage(down_arrow, forState:UIControlStateNormal)
    button_view.addEventHandler(lambda do |sender, event|
      cvc = CommentListController.alloc.init
      cvc.sid = @sid
      self.navigationController.pushViewController(cvc, animated: true)
    end, forControlEvent: UIControlEventTouchUpInside)

    arrow = UIBarButtonItem.alloc.initWithCustomView(button_view)
    modal.navigationItem.rightBarButtonItem = arrow if Device.iphone?

    modal.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("", style:UIBarButtonItemStylePlain, target:nil, action:nil)

    self.navigationController.pushViewController(modal, animated: true)
    tv.deselectRowAtIndexPath(indexPath, animated:true)
  end

  def tableView(tv, heightForRowAtIndexPath:indexPath)
    108
  end
end
