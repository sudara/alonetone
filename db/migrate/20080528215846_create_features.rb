class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.integer :featured_user_id
      t.integer :writer_id
      t.integer :views_count, :default => 0
      
      t.text :body
      t.text :teaser_text
      
      t.boolean :published, :default => false
      t.boolean :published_at, :datetime, :default => nil
      
      t.string :permalink
      
      t.timestamps
    end
  end

  def self.down
    drop_table :features
  end
end
