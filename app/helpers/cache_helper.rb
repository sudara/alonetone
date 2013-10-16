module CacheHelper 

  # A humble attempt to create better lazy expiration keys
  
  
  # creates a hash of all updated_at the items in the collection
  # faster than sorting
  # figure out if cache is still valid for a collection of < 50 items already instantiated in AR
  def cache_digest(collection)
    Digest::MD5.hexdigest(collection.collect{|a| a.updated_at}.join)
  end

end
