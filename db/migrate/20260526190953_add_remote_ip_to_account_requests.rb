class AddRemoteIpToAccountRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :account_requests, :remote_ip, :string
  end
end
