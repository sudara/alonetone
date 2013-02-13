class AddIndexesToAsset < ActiveRecord::Migration
  def change
    add_index "assets", "hotness"
  end
end
