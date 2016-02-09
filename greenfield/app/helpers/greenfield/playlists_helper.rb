module Greenfield
  module PlaylistsHelper
    def external_links_for(playlist)
      [:link1, :link2, :link3].collect do |link|
        external_link_for(playlist.send(link)) if playlist.send(link)
      end.join.html_safe
    end
    
    def external_link_for(link)
      text = case link
      when /spotify/i
        '<i class="fa fa-spotify"></i>Listen on Spotify'
      when /app\=music/i
        '<i class="fa fa-apple"></i>Listen on Apple Music'
      when /app\=itunes/i
        '<i class="fa fa-apple"></i>Buy on iTunes'
      else
        '<i class="fa fa-link"></i>Website'
      end.html_safe
      link_to(text, link, class: "download-button").html_safe
    end
  end
end
