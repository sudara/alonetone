module Greenfield
  module ApplicationHelper
    def emojify(content)
      content.gsub(/:([a-z0-9\+\-_]+):/) do |match|
        if Emoji.find_by_alias($1)
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
          user_post_attached_asset_path(asset.user, asset.alonetone_asset,
                                        asset, :format => :mp3)
      else
        Rails.application.routes.url_helpers.
          user_track_path(asset.user, asset, :format => :mp3)
      end
    end

    def list_attached_mp3_assets(assets=[])
    end
  end
end
