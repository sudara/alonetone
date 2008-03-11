class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column "login",            :string,   :limit => 40
      t.column "email",            :string,   :limit => 100
      t.column "crypted_password", :string,   :limit => 40
      t.column "salt",             :string,   :limit => 40
      t.column "activation_code",  :string,   :limit => 40
      t.column "activated_at",     :datetime
      t.column "created_at",       :datetime
      t.column "updated_at",       :datetime
      t.column "deleted_at",       :datetime
      t.column "token",            :string
      t.column "token_expires_at", :datetime
      t.column "filter",           :string
      t.column "admin",            :boolean,                 :default => false
    end
  end

  def self.down
    drop_table :users
  end
end
