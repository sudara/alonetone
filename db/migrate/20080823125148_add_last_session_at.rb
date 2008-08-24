class AddLastSessionAt < ActiveRecord::Migration
  def self.up
    add_column :users, :last_session_at, :datetime
    User.find(:all).each{|u| u.update_attribute(:last_session_at, u.last_seen_at)}
  end

  def self.down
    remove_column :users, :last_session_at
  end
end
