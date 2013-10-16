class AddStalkings < ActiveRecord::Migration
  def self.up
    create_table :stalkings do |t|
      t.integer :stalker_id
      t.integer :stalkee_id
      t.timestamps 
    end
  end

  def self.down
    drop_table :stalkings
  end
end
