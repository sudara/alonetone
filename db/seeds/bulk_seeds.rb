
# Some random listens.
100.times do
  Asset.find_each do |asset|
    User.find_each do |user|
      if rand(4) == 1
        asset.listens.create!(
          listener: user,
          track_owner: asset.user,
          user_agent: Faker::Internet.user_agent,
          ip: '127.0.0.1'
        )
      end
    end
  end
end

# Some random comments
1.upto(50) do |i|
  commentable = Asset.random_order.first
  recipient = commentable.user
  commenter = User.where.not(id: recipient.id).random_order.first
  comment = Comment.new(
    commentable: commentable,
    commenter: commenter,
    user: recipient,
    body: Faker::TvShows::TwinPeaks.quote,
    private: (rand(10) == 1),
    remote_ip: "fc00:1:1::#{i}"
  )
  # Not forcing a save because duplicate checking might throw an exception
  # here and in that case we don't care.
  comment.save
end

# Some random favorites
20.times do
  user = User.random_order.first
  asset = Asset.where.not(user_id: user.id).random_order.first
  user.toggle_favorite(asset)
end
