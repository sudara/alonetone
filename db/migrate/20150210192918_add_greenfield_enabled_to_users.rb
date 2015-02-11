class AddGreenfieldEnabledToUsers < ActiveRecord::Migration
  def up
    add_column :users, :greenfield_enabled, :boolean, :default => false

    User.find_each do |user|
      enabled = !!user.settings.try(:delete, :greenfield_enabled)
      user.update_attribute(:greenfield_enabled, true) if enabled
    end
  end
end
