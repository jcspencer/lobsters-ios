class LobstersComment
  attr_accessor :comment, :url, :author
  attr_accessor :score, :deleted
  attr_accessor :created, :updated, :sid

  # parsed json > variables
  def initialize(data)
    @url = NSURL.URLWithString(data["url"])
    @author = LobstersUser.new data["commenting_user"]
    @comment = data["comment"]
    @score = data["score"]
    @deleted = data["is_deleted"]
    @created = rfc_parse(data["created_at"])
    @updated = rfc_parse(data["updated_at"])
    @sid = data["short_id"]
  end

  def generate_description
    # generate a relative date from now
    m = YLMoment.momentWithDate @updated
    rel = m.fromNow

    # pick arrow (up, down, stale)
    arrow = pick_arrow @score

    # [time ago] by [username] | [arrow] [score]
    "%s by %s | %s %s" % [rel, @author.username, arrow, @score]
  end

  private
  # parse lobsters date (rfc)
  def rfc_parse(rdate)
    formatter = NSDateFormatter.new
    formatter.setLocale(NSLocale.alloc.initWithLocaleIdentifier("en_US_POSIX"))
    formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZZ")
    formatter.dateFromString(rdate)
  end

  # returns an arrow depending on score (up, down, stale)
  def pick_arrow(score)
    arrows = ["▲", "▼", "▣"]
    if score == 1 # score of 1 (default)
      arrows[2]
    elsif score > 1 # scores >1 (more than default)
      arrows[0]
    elsif score < 1 # scores 1< (less than default)
      arrows[1]
    end
  end
end
