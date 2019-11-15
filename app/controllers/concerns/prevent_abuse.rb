# frozen_string_literal: true

module PreventAbuse
  @@bad_ip_ranges = %w[
    195.239
    220.181
    61.135
    60.28.232
    121.14
    221.194
    117.41.183
    117.41.184
    60.169.78
    222.186
    61.160.232
    60.169.75
    60.169.78
    120.35.102
    110.84.8
    37.115.145
    195.154.181.60
    31.184.238.9
    62.210.202.176
    195.154.187.229
    5.188.210.13
    103.43.33
    103.54.103
  ].freeze

  # Whitelist of all allowed user-agents. Safari uses `cfnetwork' as user-agent when downloading
  # a file on macOS 10.4+.
  @@valid_listeners = %w[
    msie
    webkit
    quicktime
    gecko
    firefox
    netscape
    itunes
    chrome
    opera
    safari
    cfnetwork
    facebookexternalhit
    ipad
    iphone
    apple
    facebook
    stagefright
  ].freeze

  # Blacklist of all disallowed user-agents.
  @@bots = %w[bot spider baidu mp3bot]

  def is_a_bot?
    # gotta have a user agent
    return true unless request.user_agent.present?

    # can't be a blacklisted ip
    return true if is_from_a_bad_ip?

    # check user agent against both white and black lists
    !browser? || @@bots.any? { |bot_agent| user_agent.include? bot_agent }
  end

  def is_from_a_bad_ip?
    @@bad_ip_ranges.any? { |cloaked_ip| request.ip.match /^#{cloaked_ip}/ } # check bad ips
  end

  def browser?
    @@valid_listeners.any? { |valid_agent| user_agent.include? valid_agent }
  end

  def user_agent
    request.user_agent.try(:downcase)
  end
end
