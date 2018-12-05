# was seeing this issue locally when running without rescue
# can't dump `waveform`: was supposed to be a Array, but was a String. -- "[]"
failed_assets = []

Asset.find_each do |asset|
  next if asset.is_spam?

  current_count = asset.comments_count
  non_spam_count = asset.comments.include_private.count
  next if current_count == non_spam_count

  begin
    asset.update_attributes(comments_count: non_spam_count)
  rescue
    failed_assets << asset.id
  end
end