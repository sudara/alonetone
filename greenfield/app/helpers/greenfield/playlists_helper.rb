module Greenfield
  module PlaylistsHelper    
    def external_link_for(link)
      text = case link
      when /spotify/i
        '<i class="fa fa-spotify"></i>Spotify'
      when /app\=music/i
        '<i class="fa fa-apple"></i>Apple Music'
      when /app\=itunes/i
        '<i class="fa fa-apple"></i>iTunes'
      else
        '<i class="fa fa-link"></i>Website'
      end.html_safe
      link_to(text, link).html_safe
    end
  end
end
