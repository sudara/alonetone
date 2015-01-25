# This migration comes from greenfield (originally 20150125023134)
class AddLengthToGreenfieldAttachedAssets < ActiveRecord::Migration
  def change
    add_column :greenfield_attached_assets, :length, :integer
  end
end
