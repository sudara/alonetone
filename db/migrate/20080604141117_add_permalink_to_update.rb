class AddPermalinkToUpdate < ActiveRecord::Migration
  def self.up
    add_column :updates, :permalink, :string   
    Update.all.each do |update|
      # generate the permalink
      update.save
    end
  end

  def self.down
  end
end
