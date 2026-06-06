# Be sure to restart your server when you modify this file.
#
# This file eases your Rails 8.0 framework defaults upgrade.
#
# Uncomment each configuration one by one to switch to the new default.
# Once your application is ready to run with all new defaults, you can remove
# this file and set the `config.load_defaults` to `8.0`.
#
# Read the Guide for Upgrading Ruby on Rails for more info on each option.
# https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

# Set `Regexp.timeout` to `1`s by default to prevent ReDoS vulnerabilities.
# Rails.application.config.active_support.regexp_timeout = 1

# Set the ActiveSupport::MessageEncryptor default serializer to JSON.
# Rails.application.config.active_support.message_serializer = :json_allow_marshal

# Use ETag *or* Last-Modified for 304s, not both. Tightens conditional GET
# semantics to match RFC 7232 strict freshness.
# Rails.application.config.action_dispatch.strict_freshness = true

# When sqlite3 / dev parity is desired, schema load before migrate on fresh DBs.
# Rails.application.config.active_record.use_legacy_signed_id_verifier = :generate
