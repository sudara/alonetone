# frozen_string_literal: true

require "rails_helper"

RSpec.describe Update, type: :model do
  describe 'scopes' do
    it 'include comments and commenter avatar to prevent n+1 queries' do
      expect do
        Update.with_preloads.each do |update|
          update.comments.each { |comment| comment.commenter.avatar_image }
        end
      end.to perform_queries(count: 2)
    end
  end
end
