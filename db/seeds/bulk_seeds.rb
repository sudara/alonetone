require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers


puts "Populating another 100 users, 35% of them with a track or two"
100.times do
  print('.')
  name = Faker::TvShows::TwinPeaks.unique.character rescue
    Faker::TvShows::StarTrek.unique.character rescue
    Faker::TvShows::TheExpanse.unique.character
  travel_to(1.week.ago) do
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

    35.percent_of_the_time do
      (1..3).times do
        create_track(user)
      end
    end
  end
end

puts ""
puts "Adding 1-10 listens per track"
Asset.find_each do |asset|
  (1..10).times do
    travel_to(rand(7..30).days.ago) do
      asset.listens.create!(
        listener: sometimes(User.random_order.take),
        track_owner: asset.user,
        user_agent: Faker::Internet.user_agent,
        ip: Faker::Internet.ip_v4_address
      )
    end
  end
end


puts "And 100 comments..."
1.upto(100) do |i|
  travel_to(rand(7..30).days.ago) do
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
    comment.save # don't care if this fails a bit
    end
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