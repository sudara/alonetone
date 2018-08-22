module Greenfield
  module PlaylistsHelper
    def external_link_for(link)
      text = case link
             when /spotify/i
        '<i class="fa fa-spotify"></i>Spotify<span class="action-text">Stream</span>'
             when /app\=music/i
        '<i class="fa fa-apple"></i>Apple Music<span class="action-text">Stream</span>'
             when /app\=itunes/i
        '<i class="fa fa-apple"></i>iTunes<span class="action-text">Buy</span>'
             when /play\.google/i
        '<i class="fa fa-google"></i>Google<span class="action-text">Stream</span>'
             else
        '<i class="fa fa-link"></i>Website<span class="action-text">Visit</span>'
      end.html_safe
      link_to(text, link).html_safe
    end
  end
end
