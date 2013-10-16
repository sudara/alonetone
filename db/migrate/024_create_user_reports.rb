class CreateUserReports < ActiveRecord::Migration
  def self.up
    create_table :user_reports do |t|
      t.integer :user_id
      t.string :category
      t.text :description
      t.string :params
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :user_reports
  end
end
