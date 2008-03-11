xml.instruct! :xml, :version=>"1.0"
xml.rss(:version => "2.0") do
 
xml.channel do
  xml.title(@plalist.name)
    
    xml.link("http://www.xxxxx.com/xxxx")
    xml.description(@channel.description)
    xml.pubDate(CGI.rfc1123_date(@channel.shows.last.date_published))
    
    for show in @channels.shows do  
      xml.item do
        xml.title(show.name)
        xml.description(show.description)
        xml.pubDate(CGI.rfc1123_date(show.date_published))
        xml.enclosure(:url => "http://www.xxxxx.com/xxxxxxx", :type => "audio/mpeg")
      end
    end
  end
end