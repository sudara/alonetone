class AddHtmLversionsToFormattedAttributes < ActiveRecord::Migration
  def self.up
    add_column :assets, :description_html, :text
    add_column :comments, :body_html, :text
    add_column :user_reports, :description_html, :text
    add_column :updates, :content_html, :text
    add_column :users, :bio_html, :text
  end

  def self.down
  end
end
