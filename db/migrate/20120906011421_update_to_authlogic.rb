class UpdateToAuthlogic < ActiveRecord::Migration
  def up
    change_column :users, :crypted_password, :string, :limit => 128,
      :null => false, :default => ""
    change_column :users, :salt, :string, :limit => 128,
      :null => false, :default => ""
    add_column :users, "remember_token",         :string
    add_column :users, "remember_created_at",    :string
    add_column :users, "login_count",            :integer,  :null => false, :default => 0
    add_column :users, "current_login_at",       :datetime
    add_column :users, "current_login_ip",       :string
    add_column :users, :persistence_token,       :string          
    rename_column :users, :ip, :last_login_ip
  end

  def down
  end
end
