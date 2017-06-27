class AddWhiteThemeToggleToUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :last_session_at
    remove_column :users, :remember_token
    remove_column :users, :remember_created_at
    remove_column :users, :identity_url
    remove_column :users, :token_expires_at
    remove_column :users, :token
    remove_column :users, :pic_id
    remove_column :users, :myspace
    remove_column :users, :extended_bio
    remove_column :users, :deleted_at

    add_column :users, :white_theme_enabled, :boolean, default: false
  end
end
