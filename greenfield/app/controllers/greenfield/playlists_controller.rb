module Greenfield
  class PlaylistsController < Greenfield::ApplicationController
    include Listens

    def show
      @post = find_asset_from_playlist.try(:greenfield_post)
      respond_to do |format|
        format.html do
          @user = @playlist.user
          @page_title = "#{@playlist.title} — #{@user.display_name}"
        end

        format.mp3 do
          listen(@post.asset, register: false)
        end
      end
    end


    protected

    def require_login
      if find_post.user != current_user
        flash[:message] = "You'll need to login to do that"
        super(find_post.user)
      end
    end
  end
end
