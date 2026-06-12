class AddIndexToUsersCurrentLoginIp < ActiveRecord::Migration[8.1]
  def change
    add_index :users, [:current_login_ip, :deleted_at]
  end
end
