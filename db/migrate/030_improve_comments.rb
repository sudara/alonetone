class ImproveComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :owner_id
    
    # this is whomever MAKES the comment
    add_column :comments, :commenter_id, :integer

    # this is whomever RECIEVES the comment
    add_column :comments, :user_id, :integer
  end

  def self.down
  end
end
