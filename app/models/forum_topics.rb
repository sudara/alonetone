class ForumTopics
  FORUM_URL = 'https://forum.alonetone.com'.freeze
  CACHE_KEY = 'forum_topics/latest/v1'.freeze
  REFRESH_LOCK_KEY = 'forum_topics/refresh_lock'.freeze
  REFRESH_AFTER = 1.hour
  CACHE_TTL = 1.day

  Topic = Struct.new(:title, :url, :author, :author_url, keyword_init: true)

  def self.latest
    entry = Rails.cache.read(CACHE_KEY)
    enqueue_refresh if entry.nil? || stale?(entry)
    entry ? entry[:topics] : []
  rescue StandardError => e
    Rails.logger.warn("ForumTopics read failed: #{e.class}: #{e.message}")
    []
  end

  def self.refresh!(limit: 4)
    topics = fetch(limit)
    Rails.cache.write(CACHE_KEY, { topics: topics, fetched_at: Time.current }, expires_in: CACHE_TTL) if topics.any?
  rescue StandardError => e
    Rails.logger.warn("ForumTopics refresh failed: #{e.class}: #{e.message}")
  end

  def self.stale?(entry)
    Time.current - entry[:fetched_at] > REFRESH_AFTER
  end

  def self.enqueue_refresh
    return unless Rails.cache.write(REFRESH_LOCK_KEY, true, expires_in: 1.minute, unless_exist: true)

    RefreshForumTopicsJob.perform_later
  end

  def self.fetch(limit)
    uri = URI("#{FORUM_URL}/latest.json")
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 3) do |http|
      http.get(uri.request_uri)
    end
    return [] unless response.is_a?(Net::HTTPSuccess)

    parse(JSON.parse(response.body), limit)
  end

  def self.parse(json, limit)
    usernames = Array(json['users']).to_h { |user| [user['id'], user['username']] }
    json.dig('topic_list', 'topics').to_a
      .reject { |topic| topic['pinned'] }
      .first(limit)
      .map { |topic| build_topic(topic, usernames) }
  end

  def self.build_topic(topic, usernames)
    original_poster = topic['posters']&.find { |poster| poster['description'].to_s.include?('Original Poster') }
    username = usernames[(original_poster || topic['posters']&.first)&.dig('user_id')]
    Topic.new(
      title: topic['title'],
      url: "#{FORUM_URL}/t/#{topic['slug']}/#{topic['id']}",
      author: username,
      author_url: username && "#{FORUM_URL}/u/#{username}"
    )
  end
end
