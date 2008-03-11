class AddFacebookUserAndRelations < ActiveRecord::Migration
  def self.up
    # out with the old
    remove_column :users, :fb_user_id
    
    # users can have a facebook account
    add_column :users, :facebook_account_id, :integer
    
    create_table :facebook_accounts do |t|
        t.integer :fb_user_id
    end


    # bigints for mysql
    execute("alter table facebook_accounts modify fb_user_id bigint")
    
    add_index :users, :facebook_account_id
    add_index :facebook_accounts, :fb_user_id
  end

  def self.down
  end
end
