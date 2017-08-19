class DropExcessJunk < ActiveRecord::Migration[5.1]
  def change
    drop_table :facebook_accounts
    drop_table :facebook_addables
    drop_table :logged_exceptions
    remove_column :assets, :site_id
    remove_column :assets, :parent_id
    drop_table :reportable_cache
  end
end
