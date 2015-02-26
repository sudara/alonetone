class User
  has_many :greenfield_playlists, :class_name => '::Greenfield::Playlist'

  has_many :greenfield_posts, :through => :assets
end
