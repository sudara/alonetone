xml = ::Builder::XmlMarkup.new( :indent => 2 )

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.rss :version => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title "Listen feed for #{@user.display_name}"
    xml.description "A podcast feed of new tracks by artists followed by #{@user.display_name}"
    xml.link user_url( @user )
    xml.generator "alonetone.com"

    @tracks.each do |track|
      xml.item do
        xml.title "#{track.title} by #{track.user.display_name} (#{track.length})"
        xml.link user_track_url( track.user, track )
        xml.pubDate track.created_at.rfc822
        xml.description do |description|
          description.cdata!( track.description )
        end
        xml.tag!( "enclosure", :url => track.public_mp3, :length => track.size, :type => "audio/mpeg" )
        xml.tag!( "media:content", :duration => track.length )
      end
    end
  end
end
