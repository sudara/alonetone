class AddDefensioColumnsToUserReports < ActiveRecord::Migration
  def self.up
    add_column :user_reports, :spam,      :boolean, :default => false
    add_column :user_reports, :spaminess, :float
    add_column :user_reports, :signature, :string
    # Uncomment this if you wanna customize when an article is announced to Defensio server
    # add_column :article, :announced, :boolean, :default => false
  end

  def self.down
    remove_column :user_reports, :spam
    remove_column :user_reports, :spaminess
    remove_column :user_reports, :signature
    # add_column :article, :announced
  end
end
