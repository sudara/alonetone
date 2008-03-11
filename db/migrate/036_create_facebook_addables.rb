class CreateFacebookAddables < ActiveRecord::Migration
  def self.up
    create_table :facebook_addables do |t|
      t.string :profile_chunk_type
      t.integer :profile_chunk_id
      t.integer :facebook_account_id

      t.timestamps
    end
  end

  def self.down
    drop_table :facebook_addables
  end
end
