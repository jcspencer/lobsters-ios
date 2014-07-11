class StoryListController < UITableViewController
  def viewDidLoad
    # initalise view

    set_reloader # add pull to refresh to table view

    set_dropdown_menu # add dropdown menu to switch between hottest/newest

    infinite_scroll # add infinite scroll to table view

    self.tableView.setSeparatorStyle(UITableViewCellSeparatorStyleNone) # remove those pesky cell sperators

    # create an afmotion client to lobste.rs api with json encoding
    @client = AFMotion::Client.build("https://lobste.rs/") do
      header "Accept", "application/json"
      response_serializer :json
    end

    @page = 1 # current page number
    @endpoint = "hottest.json" # endpoint to pull
    @stories = [] # data source
    view.dataSource = view.delegate = self # assign self as tableview datasource

    hud = create_hud "Loading..." # create a HUD with a spinner
    refresh(@endpoint) do |data, err| # start refesh operation
      if !err # if there is no error
        @stories = data # set the datasource to the resulting array
        view.reloadData # refesh the table view
      end

      hud.hide(true) # hide the spinner hud
    end
  end

  def viewWillAppear(animated)
    self.title = "Lobsters - Hottest" # set the view title
    navigationController.setNavigationBarHidden(false, animated:true) # don't hide the nav bar
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    true # self explanitory
  end

  # add infinite scroll to the table
  def infinite_scroll
    # create a block to be called when the bottom of the table is reached
    @infinite_scroll_handler = lambda do
      @page += 1 # increnment the current page
      refresh(@endpoint) do |data, err|
        if !err # if we're ok
          @stories = @stories.concat data # push the resulting stories from the next page on the end of the current ones
          view.reloadData # refresh the table view
        end

        self.tableView.finishInfiniteScroll # stop spinning
      end
    end

    self.tableView.addInfiniteScrollWithHandler(@infinite_scroll_handler) # add the handler to the scroll view
  end

  # create a spinner hud with the provided message
  def create_hud(msg)
    spinner = RTSpinKitView.alloc.initWithStyle(RTSpinKitViewStyleWanderingCubes, color: UIColor.whiteColor)
    hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    hud.square = true
    hud.mode = MBProgressHUDModeCustomView
    hud.customView = spinner
    hud.labelText = msg
    spinner.startAnimating

    hud
  end

  # add pull to refresh to the table view
  def set_reloader
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.tintColor = UIColor.grayColor
    @refreshControl.addTarget self, action: :pull_refresh, forControlEvents:UIControlEventValueChanged
    self.refreshControl = @refreshControl
  end

  # create the endpoint selection menu
  def set_dropdown_menu
    # block called when "hottest" is selected
    @set_hottest = lambda do |i|
      @endpoint = "hottest.json" # set the endpoint to hottest
      @page = 1 # start at page one
      hud = create_hud "Loading..." # start the spinner hud
      refresh(@endpoint) do |data, err| # on response
        if !err # we're ok
          @stories = data # push the data
          view.reloadData # reload the table view
          self.title = "Lobsters - Hottest" # switch title
        end

        hud.hide(true) # hide the spinner
      end
    end

    # block called when "hottest" is selected
    @set_newest = lambda do |i|
      @endpoint = "newest.json" # set the endpoint to newest
      @page = 1 # start at page one
      hud = create_hud "Loading..." # start the spinner hud
      refresh(@endpoint) do |data, err| # on response
        if !err # we're ok
          @stories = data # push the data
          view.reloadData # reload the table view
          self.title = "Lobsters - Newest" # switch title
        end

        hud.hide(true) # hide the spinner
      end
    end

    # create REMenuItems with the selection blocks
    hottest = REMenuItem.alloc.initWithTitle("Hottest", subtitle: nil, image: nil, highlightedImage: nil, action: @set_hottest)
    newest = REMenuItem.alloc.initWithTitle("Newest", subtitle: nil, image: nil, highlightedImage: nil, action: @set_newest)
    items = [hottest, newest] # make an array

    @menu = REMenu.alloc.initWithItems(items) # create a menu with the items

    # set the right bar button item to a down arrow that toggles the menu
    down_arrow = UIImage.imageNamed("down")
    button_view = UIButton.buttonWithType(UIButtonTypeCustom)
    button_view.bounds = CGRectMake(0, 0, 32, 32)
    button_view.setImage(down_arrow, forState:UIControlStateNormal)
    button_view.addTarget(self, action: :choose_endpoint, forControlEvents:UIControlEventTouchUpInside)
    arrow = UIBarButtonItem.alloc.initWithCustomView(button_view)
    self.navigationItem.rightBarButtonItem = arrow

    true
  end

  # dropdown the endpoint menu
  def choose_endpoint
    if @menu.isOpen # toggle
      return @menu.close
    end

    #show the menu
    @menu.showFromNavigationController(self.navigationController)
  end

  # trigger pull to refresh
  def pull_refresh(refresh = true)
    refresh(@endpoint) do |data, err| # on response
      if !err # we're ok
        @stories = data # set the data
        view.reloadData # reload the table view
      end

      @refreshControl.endRefreshing # stop spinning
    end
  end

  # alert the user to errors
  def show_error(msg)
    alert = SIAlertView.alloc.initWithTitle("Oh shoot!", andMessage: msg) # create an alert view wth a title and message
    alert.transitionStyle = SIAlertViewTransitionStyleBounce # alert view bounces for transitions

    alert.addButtonWithTitle("OK", type: SIAlertViewButtonTypeDestructive, handler: nil) # ok button just closes the view and does nil
    alert.addButtonWithTitle("Try Again", type: SIAlertViewButtonTypeDefault, handler: lambda do |al| # reload button tapped (try again)
      hud = create_hud "Loading..." # create a spinner
      refresh(@endpoint) do |data, err| # on response
        if !err # we're ok
          @stories = data # set data
          view.reloadData # reload the table view
        end

        hud.hide(true) # stop the spinner
      end
    end)

    alert.show # show the alert we just created
  end

  # pull data and map it into objects
  def refresh(endpoint, &block)
    begin
      @cb = block # callback block (completion)
      @client.get(endpoint, page: @page) do |result| # call api with endpoint and page number
        if result.success? # we're ok
          data = result.object.map { |i| LobstersStory.new i } # map the objects into stories
          @cb.call data, nil # callback the results
        else # oh no
          show_error result.error.localizedDescription # show the error
          @cb.call [], result.error # callback empty handed and with an error
        end
      end
    rescue Exception => e # this is really bad
      show_error e.localizedDescription # show the error
      @cb.call [], e # callback empty handed with the error
    end
  end

  # create a uiimage at CGSize size with UIColor color
  def blank_image(size, color)
    UIGraphicsBeginImageContext(size);
    context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, size.width, size.height));
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    outputImage
  end

  # truncate text to length (def 20) with ommission (def "...")
  def truncate(t, length = 20, omis = "...")
    text = t.dup
    if text.length > length
      text = text[0...length].strip + omis
    end

    text
  end

  # Table View
  def tableView(tv, numberOfRowsInSection:section)
    @stories.size # number of rows to create
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    cid = "PostCell" # identifier
    cell = tv.dequeueReusableCellWithIdentifier(cid) ||
           UITableViewCell.alloc.initWithStyle(
                UITableViewCellStyleSubtitle,
                reuseIdentifier:cid) # create a cell with a subtitle field

    p = @stories[indexPath.row] # story at index path

    image = NZCircularImageView.alloc.initWithFrame(CGRectMake(16, 32, 64, 64)) # create a circular image view for user picture
    url = NSURL.URLWithString(p.author.avatar) # NSURL from user picture url
    image.setImageWithResizeURL(url.absoluteString) # set the curicular image views url to the user picture NSURL
    cell.addSubview(image) # add the circular image to the cell

    # add a 64x64 blank image to the cell to sit circular image on top of
    cell.imageView.image = blank_image(CGSize.new(64, 64), UIColor.clearColor)

    # set the cell title
    title = p.title # get title from post
    title = truncate(p.title, 40) unless Device.ipad? # shorten title unless using iPad
    cell.textLabel.text = title # set the cell title

    cell.detailTextLabel.text = p.generate_description # generate the cell description and set it

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator # set accessory type to arrow

    # hax to make it work
    cell.textLabel.numberOfLines = 0
    cell.detailTextLabel.numberOfLines = 0

    cell
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    s = @stories[indexPath.row] # get the corresponding story

    @sid = s.sid

    url = s.url.absoluteString # get the url from the story
    modal = SVWebViewController.alloc.initWithAddress url # create a new web view controller modal

    # create a button on the web view controller nav bar to load comments
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

    # empty back button text
    modal.navigationItem.backBarButtonItem = UIBarButtonItem.alloc.initWithTitle("", style:UIBarButtonItemStylePlain, target:nil, action:nil)

    self.navigationController.pushViewController(modal, animated: true) # push the web view controller to the screen
    tv.deselectRowAtIndexPath(indexPath, animated:true) # deselect row
  end

  def tableView(tv, heightForRowAtIndexPath:indexPath)
    108
  end
end
