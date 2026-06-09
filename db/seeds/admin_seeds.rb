require 'active_support/testing/time_helpers'
include ActiveSupport::Testing::TimeHelpers

# Everything the admin backend moderates: account requests, invites, spam,
# soft-deleted records (some old enough to perma-delete), and bot-ish listens.
# Pages of it, with creation dates spread over the year so the dashboard charts
# show real trends. Assumes a fresh DB (db:reset/db:seed); not idempotent.

moderator = User.find_by(login: 'moderator') || User.where(moderator: true).first

CANDIDATE_TYPES = %i[band musician].freeze
SPAMMER_TYPES = %i[label blogger podcaster].freeze
REVIEW_REASONS = [
  'Anthropic: genuine musician, auto-approved',
  'Anthropic: promotional / likely spam',
  'Anthropic: low-quality submission',
  'Anthropic: mass-signup pattern detected',
  'Anthropic: links to off-platform store',
  'Rakismet marked as spam'
].freeze

def seed_account_request(attrs)
  AccountRequest.create!({
    login: Faker::Internet.unique.username(specifier: 6..14, separators: []),
    email: Faker::Internet.unique.email,
    entity_type: :musician,
    details: Faker::Lorem.paragraph_by_chars(number: rand(60..400)),
    remote_ip: Faker::Internet.ip_v4_address
  }.merge(attrs))
  print('.')
rescue ActiveRecord::RecordInvalid
  print('x')
end

def days_ago(max, &block) = travel_to(rand(0..max).days.ago, &block)

puts "\nExtra users spread across the last year (realistic dashboard trends + a full Users list)..."
150.times do
  days_ago(365) do
    User.create!(
      login: Faker::Internet.unique.username(specifier: 6..14, separators: []),
      email: Faker::Internet.unique.email,
      password: SEEDS_PASSWORD,
      password_confirmation: SEEDS_PASSWORD,
      current_login_ip: Faker::Internet.ip_v4_address
    )
  rescue ActiveRecord::RecordInvalid
    nil
  end
end

puts "\nAccount requests (pages of them, all statuses, spread over 6 months)..."
55.times { days_ago(180) { seed_account_request(entity_type: CANDIDATE_TYPES.sample, status: :waiting) } }
22.times { days_ago(180) { seed_account_request(entity_type: SPAMMER_TYPES.sample, status: :waiting, review_reason: REVIEW_REASONS.sample) } }
30.times do
  days_ago(180) do
    seed_account_request(status: %i[approved denied claimed].sample, moderated_by: moderator,
      review_reason: [REVIEW_REASONS.sample, nil].sample)
  end
end

puts "\nRepeat submitters (same email, so submission_count > 1)..."
12.times do
  email = Faker::Internet.unique.email
  rand(2..4).times { days_ago(120) { seed_account_request(email: email, status: :waiting, entity_type: CANDIDATE_TYPES.sample) } }
end

puts "\nMass invites (active + archived, varied signup counts)..."
invites = []
30.times do |i|
  days_ago(240) do
    invites << MassInvite.create!(
      name: "#{Faker::Company.buzzword.capitalize} #{%w[Launch Campaign Drop Wave Invite Beta].sample}",
      archived: i >= 22
    )
  end
end
User.where(admin: false, moderator: false).random_order.limit(120).each do |user|
  MassInviteSignup.create!(mass_invite: invites.sample, user: user)
rescue ActiveRecord::RecordInvalid
  nil
end

puts "\nMore comments spread across the year (a full Comments list)..."
asset_ids = Asset.ids
150.times do
  days_ago(365) do
    asset = Asset.find(asset_ids.sample)
    Comment.create!(
      commentable: asset,
      user: asset.user,
      commenter: User.where.not(id: asset.user_id).random_order.first,
      body: Faker::TvShows::TwinPeaks.quote,
      remote_ip: Faker::Internet.ip_v4_address
    )
  rescue StandardError
    nil
  end
end

moddable_users = User.where(admin: false, moderator: false)

# Use the real command objects so soft-deletion cascades to tracks/comments/listens
# exactly like the app does — otherwise the public site hits nil owners/commentables.
puts "\nSpam users / tracks / comments (pages worth, some soft-deleted)..."
moddable_users.random_order.limit(40).each_with_index do |user, i|
  user.update_column(:is_spam, true)
  UserCommand.new(user).soft_delete_with_relations if i.even?
end
Asset.random_order.limit(45).each_with_index do |asset, i|
  asset.update_column(:is_spam, true)
  AssetCommand.new(asset).soft_delete_with_relations if i.even?
end
Comment.order(Arel.sql('RAND()')).limit(50).each { |comment| comment.update_column(:is_spam, true) }

puts "Soft-deleted records (a chunk older than 30 days, so they're perma-deletable)..."
moddable_users.where(is_spam: false).random_order.limit(40).each_with_index do |user, i|
  UserCommand.new(user).soft_delete_with_relations
  user.update_column(:deleted_at, rand(35..120).days.ago) if i < 15
end
Asset.where(is_spam: false).random_order.limit(40).each_with_index do |asset, i|
  AssetCommand.new(asset).soft_delete_with_relations
  asset.update_column(:deleted_at, rand(35..120).days.ago) if i < 15
end

puts "Clustered + bot-like listens (IPs that love to listen)..."
bot_ips = { '185.220.101.42' => 250, '45.155.205.17' => 180 }
clustered_ips = Array.new(5) { Faker::Internet.ip_v4_address }
# joins(:user) keeps only live assets whose owner isn't soft-deleted, so track_owner is never nil
listenable = Asset.joins(:user).random_order.limit(60).to_a
# no_touching so back-dated listens don't stomp each asset's updated_at to a random past date
ActiveRecord::Base.no_touching do
  bot_ips.each do |ip, count|
    count.times do
      asset = listenable.sample
      days_ago(30) { asset.listens.create!(track_owner: asset.user, ip: ip, user_agent: 'python-requests/2.31.0') }
    end
  end
  clustered_ips.each do |ip|
    rand(40..90).times do
      asset = listenable.sample
      days_ago(30) { asset.listens.create!(track_owner: asset.user, ip: ip, user_agent: Faker::Internet.user_agent) }
    end
  end
end

puts "Shared login IPs (account clusters for the Shared IPs view)..."
clusterable = moddable_users.where(is_spam: false).random_order.limit(30).to_a
Array.new(6) { Faker::Internet.ip_v4_address }.each do |ip|
  clusterable.shift(rand(2..6)).each { |user| user.update_columns(last_login_ip: ip, current_login_ip: ip) }
end

puts "Bandwidth usage (top consumers for the Bandwidth view)..."
User.where('assets_count > 0').random_order.limit(25).each do |user|
  user.update_column(:bandwidth_used, [rand(1..15), rand(15..80), rand(100..500)].sample)
end

puts "\nAdmin seed data done."
