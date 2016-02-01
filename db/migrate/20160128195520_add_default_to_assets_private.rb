class AddDefaultToAssetsPrivate < ActiveRecord::Migration
  def change
    remove_column :assets, :private
    add_column    :assets, :private, :boolean, null: false, default: false
  end
end
