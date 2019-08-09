module Greenfield
  module ApplicationHelper
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
      render 'greenfield/player/player', asset: asset
    end

    def media_url(asset)
      if asset.is_a?(Greenfield::AttachedAsset)
        Greenfield::Engine.routes.url_helpers
                          .user_post_attached_asset_path(asset.post.user, asset.alonetone_asset,
                                        asset.permalink, format: :mp3)
      else
        Greenfield::Engine.routes.url_helpers
                          .user_post_path(asset.user, asset, format: :mp3)
      end
    end

    def list_attached_mp3_assets(assets = []); end

    def owner?
      @asset && current_user && (current_user.admin? || (current_user.id == @asset.user_id))
    end
  end
end
