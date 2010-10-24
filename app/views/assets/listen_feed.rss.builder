xml = ::Builder::XmlMarkup.new( :indent => 2 )

xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
xml.rss :version => "2.0", "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title "listener feed for: #{@user.login}"
    xml.description "Podcast for listener tracks for user #{@user.login}"
    xml.link "http://alonetone.com/"
    xml.generator "alonetone.com"

    @tracks.each do |track|
      xml.item do
        xml.title "#{track.title} by #{track.user.login}"
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
