class ConvertWhiteThemeEnabledToUseOldTheme < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :white_theme_enabled, :use_old_theme

    User.update_all use_old_theme: false
  end
end
