class LobstersComment
  attr_accessor :comment, :url, :author
  attr_accessor :score, :deleted
  attr_accessor :created, :updated, :sid

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
    m = YLMoment.momentWithDate @updated
    rel = m.fromNow
    arrow = pick_arrow @score
    "%s %s | %s by %s" % [arrow, @score, rel, @author.username]
  end

  private
  def rfc_parse(iso_date)
    formatter = NSDateFormatter.new
    formatter.setLocale(NSLocale.alloc.initWithLocaleIdentifier("en_US_POSIX"))
    formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZZ")
    formatter.dateFromString(iso_date)
  end

  def pick_arrow(score)
    arrows = ["▲", "▼", "▣"]
    if score == 0
      arrows[2]
    elsif score > 0
      arrows[0]
    elsif score < 0
      arrows[1]
    end
  end

end
