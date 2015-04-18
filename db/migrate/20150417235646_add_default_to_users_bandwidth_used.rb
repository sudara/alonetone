class AddDefaultToUsersBandwidthUsed < ActiveRecord::Migration
  def up
    change_column :users, :bandwidth_used, :integer, :default => 0
    User.where('bandwidth_used IS NULL').update_all(:bandwidth_used => 0)
  end

  def down
    change_column :users, :bandwidth_used, :integer
  end
end
