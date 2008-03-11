class TweakListens < ActiveRecord::Migration
  def self.up
    remove_column :listens, :user_id
    add_column :listens, :listener_id, :integer
    add_column :listens, :track_owner_id, :integer
    add_column :listens, :source, :string
  end

  def self.down
    remove_column :listens, :listener_id
    remove_column :listens, :track_owner_id
    remove_column :listens, :source
  end
end
