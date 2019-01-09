module CacheHelper
  # A humble attempt to create better lazy expiration keys

  # creates a hash of the count + last updated_at for the
  def cache_digest(collection)
    if collection.is_a?(Array)
      collection_key = Digest::MD5.hexdigest(collection.collect(&:updated_at).join)
      name = collection.first.class
      count = collection.size
    else
      collection_key = collection.maximum(:updated_at).try(:utc).try(:to_s, :number)
      name = collection.name
      count = collection.reorder('').count
    end
    "#{name}/all-#{count}-#{collection_key}"
  end
end
