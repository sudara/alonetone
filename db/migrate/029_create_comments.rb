class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :owner_id
      t.text :body
      t.timestamps 
    end
  end

  def self.down
    drop_table :comments
  end
end
