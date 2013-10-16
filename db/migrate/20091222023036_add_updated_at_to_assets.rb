class AddUpdatedAtToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :updated_at, :datetime
  end

  def self.down
  end
end
