class ChangeToPasswordHash < ActiveRecord::Migration
  def self.up
    rename_column :users, :crypted_password, :password_hash
  end

  def self.down
    rename_column :users, :password_hash, :crypted_password
    
  end
end
