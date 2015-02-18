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
      render 'greenfield/player/player', {:asset => asset}
    end

    def media_url(asset)
      if asset.is_a?(Greenfield::AttachedAsset)
        Greenfield::Engine.routes.url_helpers.
          post_attached_asset_path(asset.alonetone_asset,
                                   asset, :format => :mp3)
      else
        Greenfield::Engine.routes.url_helpers.
          post_path(asset, :format => :mp3)
      end
    end

    def list_attached_mp3_assets(assets=[])
    end
  end
end
