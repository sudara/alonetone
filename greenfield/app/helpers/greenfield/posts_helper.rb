module Greenfield
  module PostsHelper
    def post_form_path(post)
      if post.new_record?
        user_posts_path(post.user)
      else
        user_post_path(post.user, post)
      end
    end
  end
end
