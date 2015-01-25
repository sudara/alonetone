class AddLengthToGreenfieldAttachedAssets < ActiveRecord::Migration
  def change
    add_column :greenfield_attached_assets, :length, :integer
  end
end
