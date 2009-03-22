xml.instruct! :xml, :version=>"1.0"

xml.playlist(:version => 1, :xmlns => "http://xspf.org/ns/0/") do
  xml.title("Latest Music by #{@user.name}")
  xml.info(user_home_path(@user.login))
  xml.image(@user.avatar(:album))
  xml.trackList do
    @assets.each do |track|
      xml.track do
        xml.title(track.name)
        xml.creator(@user.name)
        xml.image(@user.avatar(:album))
        xml.location(user_track_url(@user, track.permalink, :format => :mp3))
        xml.info(user_track_url(@user, track.permalink))
      end
    end
  end
end