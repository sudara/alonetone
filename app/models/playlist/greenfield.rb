class Playlist
  has_many :greenfield_downloads, class_name: '::Greenfield::PlaylistDownload', :dependent => :destroy
  accepts_nested_attributes_for :greenfield_downloads
end
