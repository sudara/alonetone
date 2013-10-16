class CreateListens < ActiveRecord::Migration
  def self.up
    create_table :listens do |t|
      t.integer :asset_id
      t.integer :user_id
      
      t.timestamps 
    end
    
    add_index :listens, :asset_id
    add_index :listens, :user_id
  end

  def self.down
    drop_table :listens
  end
end
