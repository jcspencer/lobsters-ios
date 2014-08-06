class LobstersStory
  attr_accessor :title, :url, :author
  attr_accessor :comments, :score, :tags
  attr_accessor :date, :sid

  # parsed json > variables
  def initialize(data)
    @url = NSURL.URLWithString(data["url"] == "" ? data["comments_url"] : data["url"])
    @title = data["title"]
    @author = LobstersUser.new data["submitter_user"]
    @comments = data["comment_count"]
    @score = data["score"]
    @tags = data["tags"]
    @date = rfc_parse(data["created_at"])
    @sid = data["short_id"]
  end

  def generate_description
    # get a relative date from now
    m = YLMoment.momentWithDate @date
    rel = m.fromNow

    # pick arrow (up, down, stale)
    arrow = pick_arrow @score

    # correct grammar for comment(s)
    use_s = ""
    if !@comments.eql? 1
      use_s = "s"
    end
    # [time ago] by [username]\n[arrow] [score] | [n] comment[s]\n([domain name])
    "%s by %s\n%s %s | %d comment%s\n(%s)" % [rel, @author.username, arrow, @score, @comments, use_s, @url.host]
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
