# frozen_string_literal: true
require 'faker'
require_relative 'seeds/config'
require_relative 'seeds/helpers'
require_relative 'seeds/boutique_users'
require_relative 'seeds/bulk_seeds'

group1 = Thredded::MessageboardGroup.create(name: "Alonetone", position: 1)
group2 = Thredded::MessageboardGroup.create(name: "General", position: 2)
boards = []
boards << Thredded::Messageboard.create(name: 'Ideas, Features, Praise',
  description: "Help us build out alonetone. Cheer us on and request features.", position: 1, group: group1)
boards << Thredded::Messageboard.create(name: 'Need Help? Found a Bug?',
  description: "Speak up if something isn't working! Otherwise it'll stay broken until someone else does!", position: 2, group: group1)
boards << Thredded::Messageboard.create(name: 'Making Music',
  description: "Chit chat about your process here.", position: 1, group: group2)
boards << Thredded::Messageboard.create(name: 'Gear Talk',
  description: "Tell us about your new toy or your bad case of GAS.", position: 2, group: group2)
boards.collect do |board|
  topic = board.topics.new do |t|
    user = User.all.sample
    t.user = user
    t.title = "New thread on #{board.name} that is a bit too long for previewing"
    t.posts.new do |p|
      p.user = user
      p.content = 'Here is the body of a post on #{board.name}... Good stuff!'
      p.moderation_state = 'approved'
      p.messageboard = board
      p.created_at = p.updated_at = 75.minutes.ago # prevent percy glitch
    end
    t.save
  end
end
