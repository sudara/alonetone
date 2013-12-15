class Addbandwidthusedtouser < ActiveRecord::Migration
  def change
    add_column :users, :bandwidth_used, :integer
  end
end
