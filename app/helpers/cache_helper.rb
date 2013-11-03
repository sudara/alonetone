module CacheHelper 

  # A humble attempt to create better lazy expiration keys
  
  # creates a hash of the count + last updated_at for the 
  def cache_digest(collection)
    count          = collection.count
    max_updated_at = collection.maximum(:updated_at).try(:utc).try(:to_s, :number)
    "#{collection.name}/all-#{count}-#{max_updated_at}"
  end

end
