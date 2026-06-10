require 'ipaddr'

class BannedIp < ApplicationRecord
  belongs_to :banned_by, class_name: 'User', optional: true

  validates :ip, presence: true, uniqueness: true
  validate :ip_is_a_valid_address

  before_validation :normalize_ip

  scope :recent, -> { order(created_at: :desc) }

  after_commit :clear_cache

  CACHE_KEY = 'banned_ips'.freeze

  # Matches exact bans by set lookup and CIDR bans ("47.82.0.0/16") by range inclusion.
  class Matcher
    def initialize(ips)
      exact, ranges = ips.partition { |ip| ip.exclude?('/') }
      @exact = exact.to_set
      @ranges = ranges.filter_map do |range|
        IPAddr.new(range)
      rescue IPAddr::InvalidAddressError
        nil
      end
    end

    def banned?(ip)
      return false if ip.blank?
      return true if @exact.include?(ip)

      addr = IPAddr.new(ip)
      @ranges.any? { |range| range.include?(addr) }
    rescue IPAddr::InvalidAddressError
      false
    end
  end

  def self.banned?(ip)
    matcher.banned?(ip)
  end

  def self.matcher
    Matcher.new(cached_ips)
  end

  def range?
    ip.to_s.include?('/')
  end

  # Listen rows store exact IPs, so range purges expand v4 ranges; v6 ranges aren't expandable.
  def purgeable_listens?
    !range? || IPAddr.new(ip).ipv4?
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
    errors.add(:ip, 'is not a valid IP address or CIDR range')
  end

  def normalize_ip
    value = ip.to_s.strip
    return if value.blank?

    addr = IPAddr.new(value)
    full_prefix = addr.ipv4? ? 32 : 128
    self.ip = if value.include?('/') && addr.prefix < full_prefix
                "#{addr}/#{addr.prefix}"
              else
                addr.to_s
              end
  rescue IPAddr::InvalidAddressError
    self.ip = value
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
