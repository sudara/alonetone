module Greenfield
  module PostsHelper
    def post_form_path(post)
      if post.new_record?
        user_posts_path(post.asset.user)
      else
        user_post_path(post.asset.user, post.asset.permalink)
      end
    end
  end
end
