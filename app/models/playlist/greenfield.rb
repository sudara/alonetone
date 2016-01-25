class Playlist
  has_many :greenfield_downloads, class_name: '::Greenfield::PlaylistDownload', :dependent => :destroy
end
