class AddGreenfieldEnabledToUsers < ActiveRecord::Migration
  def up
    add_column :users, :greenfield_enabled, :boolean, :default => false

    User.find_each do |user|
      user.greenfield_enabled = !!user.settings.try(:delete, :greenfield_enabled)
      user.save!
    end
  end
end
