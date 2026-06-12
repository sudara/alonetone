class SeedBannedIpsFromLegacyList < ActiveRecord::Migration[8.1]
  # The stub bypasses BannedIp#normalize_ip, so every entry below must already be in normalized form.
  class MigrationBannedIp < ActiveRecord::Base
    self.table_name = 'banned_ips'
  end

  # The PreventAbuse @@bad_ip_ranges prefixes, converted to CIDR.
  LEGACY_BANS = %w[
    195.239.0.0/16
    220.181.0.0/16
    61.135.0.0/16
    121.14.0.0/16
    221.194.0.0/16
    222.186.0.0/16
    47.82.0.0/16
    60.28.232.0/24
    117.41.183.0/24
    117.41.184.0/24
    60.169.75.0/24
    60.169.78.0/24
    61.160.232.0/24
    120.35.102.0/24
    110.84.8.0/24
    37.115.145.0/24
    103.43.33.0/24
    103.54.103.0/24
    195.154.181.60
    31.184.238.9
    62.210.202.176
    195.154.187.229
    5.188.210.13
  ].freeze

  def up
    LEGACY_BANS.each { |ip| MigrationBannedIp.find_or_create_by!(ip: ip) }
  end

  def down
    MigrationBannedIp.where(ip: LEGACY_BANS).delete_all
  end
end
