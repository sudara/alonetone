module Greenfield
  module ApplicationHelper
    def emojify(content)
      content.gsub(/:([a-z0-9\+\-_]+):/) do |match|
        if Emoji.names.include?($1)
          '<img alt="' + $1 + '" height="20" src="' + asset_path("images/emoji/#{$1}.png") + '" style="vertical-align:middle" width="20" />'
        else
          match
        end
      end.html_safe
    end

    def markdown(text, post: nil)
      return "" unless text
      text = emojify(text)
      if post
        Greenfield::Markdown.render_with_embeds(post, text)
      else
        Greenfield::Markdown.render(text)
      end
    end

    def player(asset)
      if asset.is_a?(Greenfield::AttachedAsset)
        link_url = Greenfield::Engine.routes.url_helpers.
                     user_post_attached_asset_path(asset.post.asset.user, asset.post.asset.permalink, 
                                                   asset, :format => :mp3)
      else
        link_url = Rails.application.routes.url_helpers.
                     user_track_path(asset.user.login, asset.permalink, :format => :mp3)
      end

      waveform = asset.waveform.join(', ')

      content_tag(:div, :class => 'player') do
        [
          content_tag(:i, :class => "fa fa-play fa-3x play-button play-control") do
            link_to '', link_url
          end,

          content_tag(:div, :class => 'waveform', :'data-waveform' => waveform) do
            content_tag(:div, :class => 'seekbar'){ }
          end,

          content_tag(:div, :class => 'time') do
            current = content_tag(:span, '0:00', :class => 'index')
            "#{current} of #{asset.length}".html_safe
          end,
          
          content_tag(:div, :class => 'download-button') do
            link_to '', link_url
          end
          
        ].join.html_safe
      end
    end
  end
end
