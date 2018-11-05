module Admin
  module Comments
    class MarkAsSpamController < Admin::BaseController
      def create
        if params[:id]
          scope = Comment.where(id: params[:id])
        elsif params[:user_id]
          scope = Comment.where(commenter: params[:user_id])
        end
        # limit scope to non_spam comments
        # and we should include private comments as well
        comments = scope.include_private

        comments.map(&:spam!)
        comments.update_all(is_spam: true)
        # placeholder for now before we get Stimulujs setup
        redirect_back(fallback_location: root_path)
      end
    end
  end
end
