require 'ipaddr'

class BannedIp < ApplicationRecord
  belongs_to :banned_by, class_name: 'User', optional: true

  validates :ip, presence: true, uniqueness: true
  validate :ip_is_a_valid_address

  scope :recent, -> { order(created_at: :desc) }

  after_commit :clear_cache

  CACHE_KEY = 'banned_ips'.freeze

  def self.banned?(ip)
    ip.present? && cached_ips.include?(ip)
  end

  # cached so the listen-recording hot path does one memory hit, not a query per play.
  # Fails open (empty set) if the cache or DB is unavailable — a backend blip must not break playback.
  def self.cached_ips
    Rails.cache.fetch(CACHE_KEY, expires_in: 5.minutes) { uncached_ips }
  rescue StandardError
    uncached_ips
  end

  def self.uncached_ips
    pluck(:ip).to_set
  rescue StandardError
    Set.new
  end

  def self.clear_cache
    Rails.cache.delete(CACHE_KEY)
  end

  private

  def ip_is_a_valid_address
    return if ip.blank?

    IPAddr.new(ip)
  rescue IPAddr::InvalidAddressError
    errors.add(:ip, 'is not a valid IP address')
  end

  def clear_cache
    self.class.clear_cache
  end
end

# == Schema Information
#
# Table name: banned_ips
#
#  id           :bigint(8)        not null, primary key
#  ip           :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  banned_by_id :bigint(8)
#
# Indexes
#
#  index_banned_ips_on_ip  (ip) UNIQUE
#
