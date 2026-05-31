class AddReviewReasonToAccountRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :account_requests, :review_reason, :text
  end
end
