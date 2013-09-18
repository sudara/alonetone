class RemoveDefensioAddAkismet < ActiveRecord::Migration
  def change
    # Rakismet uses a method called spam?, lets accommadate
    rename_column :comments, :spam, :is_spam
    
    # no longer needed, defensio specific
    remove_column :comments, :signature 
    
    # no longer nedeed, defensio specific
    remove_column :comments, :spaminess
    
    # I guess my spelling got better over the years
    rename_column :comments, :referer, :referrer 
  end
end
