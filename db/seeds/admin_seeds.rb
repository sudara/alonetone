require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

# Everything the admin backend moderates: account requests, invites, spam,
# soft-deleted records (some old enough to perma-delete), and bot-ish listens.
# Assumes a fresh DB (runs as part of db:reset/db:seed); not idempotent — re-run db:reset on failure.

moderator = User.find_by(login: 'moderator') || User.where(moderator: true).first

def seed_account_request(attrs)
  AccountRequest.create!({
    login: Faker::Internet.unique.username(specifier: 6..12, separators: []),
    email: Faker::Internet.unique.email,
    entity_type: :musician,
    details: Faker::Lorem.paragraph_by_chars(number: rand(60..220))
  }.merge(attrs))
  print('.')
rescue ActiveRecord::RecordInvalid
  print('x')
end

puts "\nAccount requests (waiting musicians, waiting spammers, approved/denied/claimed)..."
8.times { seed_account_request(entity_type: %i[band musician].sample, status: :waiting) }
5.times do
  seed_account_request(entity_type: %i[label blogger podcaster].sample, status: :waiting,
                       review_reason: "Anthropic: #{['promotional / likely spam', 'low-quality submission', 'mass-signup pattern'].sample}")
end
4.times { seed_account_request(status: :approved, moderated_by: moderator) }
4.times { seed_account_request(status: :denied, moderated_by: moderator, review_reason: 'Rakismet marked as spam') }
3.times { seed_account_request(status: :claimed) }

puts "\nRepeat submitters (same email, so submission_count > 1)..."
3.times do
  email = Faker::Internet.unique.email
  rand(2..3).times { seed_account_request(email: email, status: :waiting, entity_type: :musician) }
end

puts "\nMass invites (active + archived, with signups)..."
active_invites = Array.new(2) { MassInvite.create!(name: "#{Faker::Company.buzzword.capitalize} Launch", archived: false) }
2.times { MassInvite.create!(name: "#{Faker::Company.buzzword.capitalize} #{rand(2018..2023)}", archived: true) }
User.where(admin: false, moderator: false).random_order.limit(rand(5..10)).each do |user|
  MassInviteSignup.create!(mass_invite: active_invites.sample, user: user)
rescue ActiveRecord::RecordInvalid
  nil
end

moddable_users = User.where(admin: false, moderator: false)

puts "\nSpam users / tracks / comments (some soft-deleted)..."
moddable_users.random_order.limit(6).each_with_index do |user, i|
  user.update_column(:is_spam, true)
  user.soft_delete if i.even?
end
Asset.random_order.limit(8).each_with_index do |asset, i|
  asset.update_column(:is_spam, true)
  asset.soft_delete if i.even?
end
Comment.order(Arel.sql('RAND()')).limit(10).each { |comment| comment.update_column(:is_spam, true) }

puts "Soft-deleted records (a couple older than 30 days, so they're perma-deletable)..."
moddable_users.where(is_spam: false).random_order.limit(5).each_with_index do |user, i|
  user.soft_delete
  user.update_column(:deleted_at, rand(35..90).days.ago) if i < 2
end
Asset.where(is_spam: false).random_order.limit(6).each_with_index do |asset, i|
  asset.soft_delete
  asset.update_column(:deleted_at, rand(35..90).days.ago) if i < 2
end

puts "Clustered + bot-like listens (one IP that loves to listen)..."
bot_ip = '185.220.101.42'
clustered_ips = Array.new(3) { Faker::Internet.ip_v4_address }
listenable = Asset.with_deleted.random_order.limit(40).to_a
# no_touching so back-dated listens don't stomp each asset's updated_at to a random past date
ActiveRecord::Base.no_touching do
  200.times do
    asset = listenable.sample
    travel_to(rand(1..30).days.ago) do
      asset.listens.create!(track_owner: asset.user, ip: bot_ip, user_agent: 'python-requests/2.31.0')
    end
  end
  clustered_ips.each do |ip|
    rand(40..80).times do
      asset = listenable.sample
      travel_to(rand(1..30).days.ago) do
        asset.listens.create!(track_owner: asset.user, ip: ip, user_agent: Faker::Internet.user_agent)
      end
    end
  end
end

puts "\nAdmin seed data done."
