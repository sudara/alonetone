class AddPrivateToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :private, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :private
  end
end
