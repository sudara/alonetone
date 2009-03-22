xml.instruct! :xml, :version=>"1.0"

xml.playlist(:version => 1, :xmlns => "http://xspf.org/ns/0/") do
  xml.title("#{@playlist.title} by #{@playlist.user.name}")
  xml.info(user_playlist_url(@user, @playlist.permalink))
  xml.image(@playlist.cover(:large))
  xml.trackList do
    @playlist.tracks.each do |track|
      xml.track do
        xml.title(track.asset.name)
        xml.creator(track.asset.user.name)
        xml.image(@playlist.cover(:large))
        xml.location(user_track_url(track.asset.user, track.asset.permalink, :format => :mp3))
        xml.info(user_track_url(track.asset.user, track.asset.permalink))
      end
    end
  end
end