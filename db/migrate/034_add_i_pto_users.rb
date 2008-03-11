class AddIPtoUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ip, :string
  end

  def self.down
  end
end
