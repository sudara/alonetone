class AddDefensioToForums < ActiveRecord::Migration
  def self.up
    add_column :topics, :spam, :boolean, :default => false
    add_column :topics, :spaminess, :float
    add_column :topics, :signature, :string
    
    add_column :posts, :spam, :boolean, :default => false
    add_column :posts, :spaminess, :float
    add_column :posts, :signature, :string


  end

  def self.down
  end
end
