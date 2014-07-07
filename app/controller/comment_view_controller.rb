class CommentListController < UITableViewController

  def sid=(value)
    @sid = value
    @endpoint = "s/" + value + ".json"
  end

  def viewDidLoad
    set_reloader
    self.tableView.setSeparatorStyle(UITableViewCellSeparatorStyleNone)

    @client = AFMotion::Client.build("https://lobste.rs/") do
      header "Accept", "application/json"
      response_serializer :json
    end
  end

  def viewWillAppear(animated)
    self.title = "Comments"

    @endpoint = "s/" + @sid + ".json"
    @comments = []
    view.dataSource = view.delegate = self

    hud = create_hud "Loading..."
    refresh(@endpoint) do |data|
      @comments = data
      view.reloadData
      hud.hide(true)
    end
    navigationController.setNavigationBarHidden(false, animated:true)
  end

  # create a loader hud
  def create_hud(msg)
    spinner = RTSpinKitView.alloc.initWithStyle(RTSpinKitViewStyleWanderingCubes, color: UIColor.whiteColor)
    hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    hud.square = true
    hud.mode = MBProgressHUDModeCustomView
    hud.customView = spinner
    #hud.labelText = msg
    spinner.startAnimating

    hud
  end

  # add pull to refresh
  def set_reloader
    @refreshControl = UIRefreshControl.alloc.init
    @refreshControl.tintColor = UIColor.magentaColor
    @refreshControl.addTarget self, action: :pull_refresh, forControlEvents:UIControlEventValueChanged
    self.refreshControl = @refreshControl
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
    alert = UIAlertView.alloc.initWithTitle("Error", message: msg, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
    alert.show
  end

  # reload the table view
  def refresh(endpoint, &block)
    begin
      @cb = block
      @client.get(endpoint) do |result|
        if result.success?
          data = result.object["comments"].map { |i| LobstersComment.new i }
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
    @comments.size
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    cid = "PostCell"
    cell = tv.dequeueReusableCellWithIdentifier(cid) ||
           UITableViewCell.alloc.initWithStyle(
                UITableViewCellStyleSubtitle,
                reuseIdentifier:cid)

    c = @comments[indexPath.row]

    image = NZCircularImageView.alloc.initWithFrame(CGRectMake(16, 32, 64, 64))
    url = NSURL.URLWithString(c.author.avatar)
    image.setImageWithResizeURL(url.absoluteString)
    cell.addSubview(image)

    cell.imageView.image = blank_image(CGSize.new(64, 64), UIColor.clearColor)

    title = c.comment
    title = truncate(c.comment, 256) unless Device.ipad?
    cell.textLabel.AttributedText = attributedStringWithHTML(title)
    cell.detailTextLabel.text = c.generate_description
    cell.detailTextLabel.font = UIFont.systemFontOfSize 10.0
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator

    cell.textLabel.numberOfLines = 0
    cell.detailTextLabel.numberOfLines = 0

    cell
  end

  def attributedStringWithHTML(html)
    style = "<meta charset=\"UTF-8\"><style> body { font-family: 'HelveticaNeue'; font-size: 10px; } b {font-family: 'MarkerFelt-Wide'; }</style>"

    styled = NSString.stringWithFormat("%@%@", style, html)
    options = { NSDocumentTypeDocumentAttribute => NSHTMLTextDocumentType }
    ret = NSAttributedString.alloc.initWithData(styled.dataUsingEncoding(NSUTF8StringEncoding), options: options, documentAttributes:nil, error:nil)
  end

  def tableView(tv, didSelectRowAtIndexPath:indexPath)
    url = @comments[indexPath.row].url.absoluteString
    modal = SVWebViewController.alloc.initWithAddress url
    self.navigationController.pushViewController(modal, animated: true)
    tv.deselectRowAtIndexPath(indexPath, animated:true)
  end

  def tableView(tv, heightForRowAtIndexPath:indexPath)
    128
  end
end
