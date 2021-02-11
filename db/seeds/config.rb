# Authlogic does not initialize when the database wasn't created when the
# Rails process starts. We need to force a User reload at this point to
# have full access to all the Authlogic methods.
Rails.application.reloader.reload! unless User.new.respond_to?(:password)

# Tell Raskimet we're in testing mode is it doesn't attempt to train based on
# any API requests from the seeds.
Rails.application.config.rakismet.test = true

# In the test environment we do things like screenshot comparison, etc
# We don't want our data changing screenshot to screenshot
Faker::Config.random = Random.new(42) if Rails.env.test?