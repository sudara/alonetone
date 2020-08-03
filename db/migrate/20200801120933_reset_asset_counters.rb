class ResetAssetCounters < ActiveRecord::Migration[6.0]
  def change
    User.find_each do |u|
      # this is no longer a counter cache column
      u.update_attribute(:assets_count, u.assets.count)
    end
  end
end
