require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

travel_to(1.week.ago)

puts "Populating another 50 users, 50% musicians with a track or two"
50.times do
  print('.')
  name = sometimes ? Faker::TvShows::TwinPeaks.unique.character : Faker::TvShows::StarTrek.unique.character
  user = User.create!(
    login: Faker::Internet.username(specifier: name, separators: [""]),
    display_name: sometimes(name, otherwise: nil),
    email: Faker::Internet.email,
    password: SEEDS_PASSWORD,
    password_confirmation: SEEDS_PASSWORD,
    current_login_ip: Faker::Internet.ip_v4_address
  )
  25.percent_of_the_time do
    user.create_patron
  end

  sometimes do
    (1..3).times do
      travel_to(rand(7..30).days.ago)
      create_track(user)
      travel_back
    end
  end
end

puts "Adding 1-10 listens per track"
Asset.find_each do |asset|
  (1..10).times do
    travel_to(rand(7..30).days.ago)
    asset.listens.create!(
      listener: sometimes(User.random_order.take),
      track_owner: asset.user,
      user_agent: Faker::Internet.user_agent,
      ip: Faker::Internet.ip_v4_address
    )
  end
end


puts "And 100 comments..."
1.upto(100) do |i|
  travel_to(rand(7..30).days.ago)
  commentable = Asset.random_order.first
  recipient = commentable.user
  commenter = User.where.not(id: recipient.id).random_order.first
  comment = Comment.new(
    commentable: commentable,
    commenter: sometimes(commenter),
    user: recipient,
    body: Faker::TvShows::TwinPeaks.quote,
    private: rarely,
    remote_ip: Faker::Internet.ip_v4_address
  )
  # Not forcing a save because duplicate checking might throw an exception
  # here and in that case we don't care.
  comment.save
end

# favorites
puts "And 100 favorites"
100.times do
  user = User.random_order.first
  asset = Asset.where.not(user_id: user.id).random_order.first
  user.toggle_favorite(asset)
end

# following
puts "Making it very social (0-100 follows per account)"
User.find_each do |user|
  sometimes(rand(10..100), otherwise: rand(0..10)).times do
    user.add_or_remove_followee(User.random_order.first)
  end
end