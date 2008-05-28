class AddListensIndex < ActiveRecord::Migration
  def self.up
    add_index :listens, :created_at
  end

  def self.down
  end
end
