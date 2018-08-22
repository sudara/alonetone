class User
  has_many :posts,  -> { order("#{Post.table_name}.created_at desc") }
  has_many :topics, -> { order("topics.created_at desc") }

  # Creates new topic and post.
  # Only..
  #  - sets sticky/locked bits if you're a moderator or admin
  #  - changes forum_id if you're an admin
  #
  def post(forum, attributes, request)
    new_topic = Topic.new(attributes.permit(:body)) do |topic|
      topic.forum = forum
      topic.user  = self
      revise_topic(topic, attributes)
      post = reply(topic, topic.body, request) unless topic.locked?
      topic.body = nil
    end
    new_topic.update_column :spam, new_topic.posts.first.is_spam?
    new_topic
  end

  def reply(topic, body, _request)
    topic.posts.new do |post|
      post.body = body
      post.forum = topic.forum
      post.user  = self
      post.save
    end
  end

  def revise(record, attributes)
    case record
    when Topic then revise_topic(record, attributes)
    when Post  then post.save
    else raise "Invalid record to revise: #{record.class.name.inspect}"
    end
    record
  end

  def can_post?
    (Time.now - created_at) >= 1.hour
  end

  def self.prefetch_from(records)
    select('distinct *').where(['id in (?)', records.pluck(:user_id).uniq])
  end

  def self.index_from(records)
    prefetch_from(records).index_by(&:id)
  end

  protected

  def revise_topic(topic, attributes)
    topic.forum_id = attributes[:forum_id] if attributes[:forum_id]

    topic.title = attributes[:title] if attributes[:title]

    if moderator?
      topic.sticky = attributes[:sticky]
      topic.locked = attributes[:locked]
    end

    topic.save
  end
end
