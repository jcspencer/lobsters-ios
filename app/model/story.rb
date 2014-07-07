class LobstersStory
  attr_accessor :title, :url, :author
  attr_accessor :comments, :score, :tags
  attr_accessor :date, :sid

  def initialize(data)
    @url = NSURL.URLWithString(data["url"])
    @title = data["title"]
    @author = LobstersUser.new data["submitter_user"]
    @comments = data["comment_count"]
    @score = data["score"]
    @tags = data["tags"]
    @date = rfc_parse(data["created_at"])
    @sid = data["short_id"]
  end

  def generate_description
    m = YLMoment.momentWithDate @date
    rel = m.fromNow
    arrow = pick_arrow @score
    use_s = ""
    if !@comments.eql? 1
      use_s = "s"
    end
    # [time ago] by [username]\n[arrow] [score] | [n] comment[s]\n([domain name])
    "%s by %s\n%s %s | %d comment%s\n(%s)" % [rel, @author.username, arrow, @score, @comments, use_s, @url.host]
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

  private
  def rfc_parse(iso_date)
    formatter = NSDateFormatter.new
    formatter.setLocale(NSLocale.alloc.initWithLocaleIdentifier("en_US_POSIX"))
    formatter.setDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZZZ")
    formatter.dateFromString(iso_date)
  end
end
