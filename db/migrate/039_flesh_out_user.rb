class FleshOutUser < ActiveRecord::Migration
  def self.up
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :extended_bio, :text
    add_column :users, :myspace, :string
    add_column :users, :settings, :string
  end

  def self.down
  end
end
