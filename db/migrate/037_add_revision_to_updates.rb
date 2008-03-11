class AddRevisionToUpdates < ActiveRecord::Migration
  def self.up
    add_column :updates, :revision, :integer
  end

  def self.down
  end
end
