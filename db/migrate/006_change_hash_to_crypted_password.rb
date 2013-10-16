class ChangeHashToCryptedPassword < ActiveRecord::Migration
  def self.up
    remove_column :users, :password_hash
    add_column :users, :crypted_password, :string, :limit => 40
  end

  def self.down
    remove_column :users, :crypted_password
    add_column :users, :password_hash, :string, :limit => 40
  end
end
