class AddIPtoListens < ActiveRecord::Migration
  def self.up
    add_column :listens, :ip, :string
  end

  def self.down
  end
end
