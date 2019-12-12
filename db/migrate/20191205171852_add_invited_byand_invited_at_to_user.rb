class AddInvitedByandInvitedAtToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :invited_by_id, :integer
    add_column :account_requests, :moderated_by_id, :integer
  end
end
