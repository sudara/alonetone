class AddFbUserIds < ActiveRecord::Migration
  def self.up
    add_column :users, :fb_user_id, :integer

        #if mysql
    execute("alter table users modify fb_user_id bigint")
    
    add_index :users, :fb_user_id
  end

  def self.down
  end
end
