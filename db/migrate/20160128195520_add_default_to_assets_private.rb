class AddDefaultToAssetsPrivate < ActiveRecord::Migration
  def change
    execute "UPDATE assets SET private = 'f'"
    change_column :assets, :private, :boolean, null: false, default: false
  end
end
