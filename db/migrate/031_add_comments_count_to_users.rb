class AddCommentsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :comments_count, :integer, :default => '0'
  end

  def self.down
  end
end
