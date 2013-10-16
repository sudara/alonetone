class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table "assets", :force => true do |t|
      t.column "content_type",     :string
      t.column "filename",         :string
      t.column "size",             :integer
      t.column "parent_id",        :integer
      t.column "thumbnail",        :string
      t.column "width",            :integer
      t.column "height",           :integer
      t.column "site_id",          :integer
      t.column "created_at",       :datetime
      t.column "title",            :string
      t.column "thumbnails_count", :integer,  :default => 0
      t.column "user_id",          :integer
    end
  end

  def self.down
    drop_table :assets
  end
end
