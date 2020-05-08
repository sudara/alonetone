class RenameNewSettingsToSettings < ActiveRecord::Migration[6.0]
  def change
    rename_table :new_settings, :settings
  end
end
