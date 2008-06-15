class CreateForums < ActiveRecord::Migration
  def self.up
    create_table "forums", :force => true do |t|
      t.integer "site_id"
      t.string  "name"
      t.string  "description"
      t.integer "topics_count",     :default => 0
      t.integer "posts_count",      :default => 0
      t.integer "position",         :default => 0
      t.text    "description_html"
      t.string  "state",            :default => "public"
      t.string  "permalink"
    end

    add_index "forums", "position"
    add_index "forums", "permalink"
  end

  def self.down
    drop_table :forums
  end
end
