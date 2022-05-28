# frozen_string_literal: true

# Proxies string values for a license to produce useful data for the website.
class License
  CURRENT_VERSION = '4.0'
  VERSION_RE = /\A[\d.]+\Z/.freeze
  # rubocop:disable Layout/LineLength
  ICONS = {
    cc: '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="32.3" cy="32" r="28.8" fill="#fff"/><path d="M32 0a31.2 31.2 0 0 1 29.7 19.7 32.6 32.6 0 0 1 0 24.6A32.9 32.9 0 0 1 32 64a31.1 31.1 0 0 1-22.6-9.5A31.9 31.9 0 0 1 31.9 0zm0 5.8c-7.3 0-13.4 2.5-18.4 7.6A27.5 27.5 0 0 0 7.8 22a25.2 25.2 0 0 0 0 20 26.5 26.5 0 0 0 43 8.3c5-4.8 7.4-11 7.4-18.3a26.3 26.3 0 0 0-7.6-18.5 25.3 25.3 0 0 0-18.5-7.7zm-.3 20.9l-4.3 2.2c-.5-1-1-1.6-1.7-2-.7-.4-1.3-.6-1.9-.6-2.8 0-4.3 2-4.3 5.7 0 1.7.4 3 1.1 4.1.7 1 1.8 1.6 3.2 1.6 1.9 0 3.2-1 4-2.8l4 2a9.4 9.4 0 0 1-8.5 5c-2.8 0-5.2-.8-6.9-2.6a9.9 9.9 0 0 1-2.6-7.3c0-3 .9-5.5 2.6-7.3a9 9 0 0 1 6.7-2.6c4 0 6.8 1.5 8.6 4.6zm18.4 0L46 28.9c-.5-1-1-1.6-1.7-2-.7-.4-1.3-.6-2-.6-2.8 0-4.2 2-4.2 5.7 0 1.7.4 3 1 4.1.8 1 1.9 1.6 3.3 1.6 1.8 0 3.2-1 4-2.8l4 2c-1 1.6-2.1 2.8-3.6 3.7a9.2 9.2 0 0 1-4.9 1.3c-2.9 0-5.2-.8-7-2.6a10 10 0 0 1-2.5-7.3c0-3 .9-5.5 2.6-7.3a9 9 0 0 1 6.8-2.6c4 0 6.7 1.5 8.4 4.6z" fill-rule="nonzero"/></svg>',
    by: '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="32.1" cy="32.3" r="28.3" fill="#fff"/><path d="M32 0c9 0 16.5 3 22.7 9.3A31 31 0 0 1 64 32c0 9-3 16.5-9.1 22.5a31.6 31.6 0 0 1-23 9.5 31 31 0 0 1-22.5-9.4A30.8 30.8 0 0 1 0 32c0-8.8 3.1-16.3 9.4-22.7A30.6 30.6 0 0 1 32 0zm0 5.8a25 25 0 0 0-18.4 7.6 25.7 25.7 0 0 0 0 37A25.3 25.3 0 0 0 32 58.2c7 0 13.3-2.6 18.6-7.9 5-4.8 7.5-11 7.5-18.3 0-7.3-2.5-13.5-7.6-18.6A25.2 25.2 0 0 0 32 5.8zM40.7 24v13H37v15.6H27V37h-3.6v-13c0-.6.2-1.1.6-1.5a2 2 0 0 1 1.4-.6h13.2c.5 0 1 .2 1.4.6.4.4.6.9.6 1.5zm-13-8.3c0-3 1.4-4.5 4.4-4.5 3 0 4.5 1.5 4.5 4.5S35 20.3 32 20.3s-4.5-1.5-4.5-4.5z" fill-rule="nonzero"/></svg>',
    nc: '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="32" cy="32.2" r="29.5" fill="#fff"/><path d="M32 0c9 0 16.5 3 22.7 9.3A30.8 30.8 0 0 1 64 32c0 9-3 16.5-9.1 22.5a31.6 31.6 0 0 1-45.5 0A30.7 30.7 0 0 1 0 32c0-8.8 3.1-16.3 9.4-22.7A30.6 30.6 0 0 1 32 0zM7.1 23.4c-1 2.6-1.4 5.5-1.4 8.6 0 7 2.6 13.2 7.7 18.4a25.5 25.5 0 0 0 18.6 7.7c7.2 0 13.4-2.6 18.6-7.8 1.9-1.8 3.3-3.7 4.4-5.6l-12-5.4c-.5 2-1.5 3.7-3.1 5-1.7 1.2-3.6 2-5.8 2.2v4.9h-3.7v-5c-3.5 0-6.8-1.3-9.7-3.8l4.4-4.4c2 2 4.5 2.9 7.1 2.9 1.1 0 2-.3 2.9-.8.8-.5 1.1-1.3 1.1-2.4 0-.8-.2-1.5-.8-2l-3.1-1.3-3.8-1.7-5-2.2-16.4-7.3zM32.1 5.7c-7.3 0-13.5 2.6-18.5 7.7a30.6 30.6 0 0 0-3.5 4.3l12.2 5.5c.5-1.7 1.5-3 3-4s3.2-1.6 5.2-1.7v-5h3.7v5c3 .1 5.6 1.1 8 3l-4.1 4.2a9.5 9.5 0 0 0-5.5-1.8 6 6 0 0 0-2.7.5c-.8.4-1.2 1-1.2 2l.3.8 4 1.8 2.9 1.3 5.1 2.2L57.4 39c.6-2.3.8-4.6.8-6.9a25 25 0 0 0-7.6-18.6A25 25 0 0 0 32 5.7z" fill-rule="nonzero"/></svg>',
    nd: '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="32.1" cy="31.8" r="29" fill="#fff"/><path d="M32 0a31 31 0 0 1 22.7 9.3A30.8 30.8 0 0 1 64 32c0 9-3 16.5-9.1 22.5-6.5 6.3-14.1 9.5-23 9.5a31 31 0 0 1-22.5-9.4A30.8 30.8 0 0 1 0 32c0-8.7 3.1-16.3 9.4-22.7A30.7 30.7 0 0 1 32 0zm0 5.8c-7.2 0-13.4 2.5-18.4 7.7a25.6 25.6 0 0 0 0 36.9A25.3 25.3 0 0 0 32 58.2c7 0 13.3-2.6 18.6-7.9 5-4.8 7.5-11 7.5-18.3a25 25 0 0 0-7.6-18.5A25 25 0 0 0 32 5.8zm12.1 18.7v5.4H21v-5.4H44zm0 10.2v5.5H21v-5.5H44z" fill-rule="nonzero"/></svg>',
    sa: '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="31.4" cy="32.1" r="29.1" fill="#fff"/><path d="M32 0a31 31 0 0 1 22.7 9.3A30.8 30.8 0 0 1 64 32c0 9-3 16.5-9.1 22.5-6.5 6.3-14.1 9.5-23 9.5a31 31 0 0 1-22.5-9.4A30.8 30.8 0 0 1 0 32c0-8.7 3.1-16.3 9.4-22.7A30.7 30.7 0 0 1 32 0zm0 5.8c-7.2 0-13.4 2.5-18.4 7.7a25.6 25.6 0 0 0 0 36.9A25.3 25.3 0 0 0 32 58.2c7 0 13.3-2.6 18.6-7.9 5-4.8 7.5-11 7.5-18.3a25 25 0 0 0-7.6-18.5A25 25 0 0 0 32 5.8zM17.9 27.5c.6-4 2.2-7 4.7-9.1a14 14 0 0 1 9.3-3.3c5 0 9 1.7 12 4.9s4.5 7.4 4.5 12.5c0 4.9-1.6 9-4.6 12.2-3.1 3.3-7.1 4.9-12 4.9a13.8 13.8 0 0 1-14.1-12.5h8c.2 3.9 2.5 5.8 7 5.8 2.3 0 4-1 5.5-2.9 1.3-2 2-4.5 2-7.8 0-3.4-.6-6-1.9-7.7a6.3 6.3 0 0 0-5.4-2.7c-4.3 0-6.7 2-7.2 5.7h2.3l-6.3 6.3-6.3-6.3h2.5z" fill-rule="nonzero"/></svg>',
    'all-rights-reserved': '<svg viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg" fill-rule="evenodd" clip-rule="evenodd" stroke-linejoin="round" stroke-miterlimit="1.4"><circle cx="32.1" cy="32.3" r="28.3" fill="#fff"/><path d="M32 0c9 0 16.5 3 22.7 9.3A31 31 0 0 1 64 32c0 9-3 16.5-9.1 22.5a31.6 31.6 0 0 1-23 9.5 31 31 0 0 1-22.5-9.4A30.8 30.8 0 0 1 0 32c0-8.8 3.1-16.3 9.4-22.7A30.6 30.6 0 0 1 32 0zm0 5.8a25 25 0 0 0-18.4 7.6 25.7 25.7 0 0 0 0 37A25.3 25.3 0 0 0 32 58.2c7 0 13.3-2.6 18.6-7.9 5-4.8 7.5-11 7.5-18.3 0-7.3-2.5-13.5-7.6-18.6A25.2 25.2 0 0 0 32 5.8z" fill-rule="nonzero"/><path d="M47.6 37.4h-6.4a6.6 6.6 0 0 1-2.5 4.5 8.6 8.6 0 0 1-5.4 1.6c-1.4 0-2.7-.3-3.9-.9a9.1 9.1 0 0 1-2.9-2.4c-.8-1-1.4-2.2-1.9-3.6-.4-1.4-.6-2.9-.6-4.4 0-3.3.7-6 2.3-8a8 8 0 0 1 6.8-3.1c2 0 3.8.5 5.3 1.5a7 7 0 0 1 2.8 4.4h6.1c-.2-2-.8-3.8-1.6-5.3a12.8 12.8 0 0 0-7.4-6.1 17.6 17.6 0 0 0-12.2.6 15.2 15.2 0 0 0-8.5 9.2 20.9 20.9 0 0 0 0 13.9 15.6 15.6 0 0 0 8.7 9.2 17.4 17.4 0 0 0 12 .5 13.5 13.5 0 0 0 7.5-6.4c.9-1.5 1.5-3.3 1.8-5.2z" fill-rule="nonzero"/></svg>'
  }.freeze
  # rubocop:enable Layout/LineLength

  attr_reader :name_with_version

  def initialize(name_with_version)
    @name_with_version = name_with_version
  end

  def name
    name_with_version.split('/', 2)[0]
  end

  def version
    name_with_version.split('/', 2)[1]
  end

  def jurisdiction
    'international'
  end

  def current?
    if %w[all-rights-reserved defined-in-content].include?(name)
      true
    else
      self.class.parse_version(version) == self.class.parse_version(CURRENT_VERSION)
    end
  end

  def current_version
    return self if current?

    License.new("#{name}/#{CURRENT_VERSION}")
  end

  def supported?
    case name_with_version
    when 'all-rights-reserved'
      true
    else
      name.present? && !!VERSION_RE.match(version.to_s)
    end
  end

  def label
    I18n.t("licenses.label.#{name}", version: '', jurisdiction: '').strip
  end

  def full_label
    I18n.t(
      "licenses.label.#{name}",
      version: version,
      jurisdiction: I18n.t("licenses.jurisdiction.#{jurisdiction}")
    ).strip
  end
  alias to_s full_label

  def short_label
    if version.present?
      "#{name.upcase} #{version}"
    end
  end

  def help
    I18n.t("licenses.help.#{name}")
  end

  def url
    return unless  version.present?

    "https://creativecommons.org/licenses/#{name_with_version}/deed.en"
  end

  def icons
    if version.present?
      (['cc'] + name.split('-')).map { |code| ICONS[code.to_sym] }.join.html_safe
    else
      ICONS[name.to_sym].html_safe
    end
  end

  def ==(other)
    other.is_a?(License) && name_with_version == other.name_with_version
  end

  def self.supported?(name_with_version)
    new(name_with_version).supported?
  end

  def self.find(name)
    all.find do |license|
      license.name == name
    end
  end

  def self.default
    License.new('all-rights-reserved')
  end

  def self.others
    codes.map do |id|
      License.new("#{id}/#{CURRENT_VERSION}")
    end
  end

  def self.all
    [default] + others
  end

  def self.codes
    %w[by by-nc by-nc-nd by-nc-sa by-nd by-sa]
  end

  def self.parse_version(version)
    version.to_s.split('.').map(&:to_i)
  end
end
