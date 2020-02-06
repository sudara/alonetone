class AddUserIdToAccountRequest < ActiveRecord::Migration[6.0]
  def change
    add_reference :account_requests, :user
  end
end
