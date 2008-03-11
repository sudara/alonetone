class FacebookAddable < ActiveRecord::Base
  # The owner
  belongs_to :facebook_account
  
  # The things we want the owner to be able to add
  belongs_to :profile_chunk, :polymorphic => true
  
  # Each addable item gets it's own entry here so the owner can reference it directly 
  belongs_to :asset,    :class_name => "Asset",
                        :foreign_key => "profile_chunk_id"
  belongs_to :playlist, :class_name => "Playlist",
                        :foreign_key => "profile_chunk_id"
                        
  validates_presence_of :profile_chunk_id, :profile_chunk_type, :facebook_account_id 
end
