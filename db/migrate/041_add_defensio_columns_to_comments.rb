class AddDefensioColumnsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :spam,      :boolean, :default => false
    add_column :comments, :spaminess, :float
    add_column :comments, :signature, :string
    # Uncomment this if you wanna customize when an article is announced to Defensio server
    # add_column :article, :announced, :boolean, :default => false
  end

  def self.down
    remove_column :comments, :spam
    remove_column :comments, :spaminess
    remove_column :comments, :signature
    # add_column :article, :announced
  end
end
