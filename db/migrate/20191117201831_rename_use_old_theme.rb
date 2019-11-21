class RenameUseOldTheme < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :use_old_theme, :dark_theme
  end
end
