class AddPerishableTokenForAuthlogic < ActiveRecord::Migration
  def up
    # activation stuff now handled by authlogic
    add_column :users, :perishable_token, :string, :default => nil
    remove_column :users, :activation_code
    
    # rename since authlogic handles this now
    rename_column :users, :last_seen_at, :last_login_at
    
    # unused/old shit in user
    remove_column :users, :facebook_account_id
  end

  def down
  end
end
