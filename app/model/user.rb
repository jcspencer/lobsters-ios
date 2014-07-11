class LobstersUser
  attr_accessor :username
  attr_accessor :admin, :mod
  attr_accessor :avatar

  # parsed json > variables
  def initialize(data)
    @username = data["username"]
    @admin = data["is_admin"]
    @mod = data["is_moderator"]
    @avatar = data["avatar_url"]
  end
end
