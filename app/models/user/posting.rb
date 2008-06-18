class User
  
  has_many :posts, :order => "#{Post.table_name}.created_at desc"
  has_many :topics, :order => "#{Topic.table_name}.created_at desc"
  # Creates new topic and post.
  # Only..
  #  - sets sticky/locked bits if you're a moderator or admin 
  #  - changes forum_id if you're an admin
  #
  def post(forum, attributes)
    attributes.symbolize_keys!
    Topic.new(attributes) do |topic|
      topic.forum = forum
      topic.user  = self
      revise_topic topic, attributes
    end
  end

  def reply(topic, body)
    returning topic.posts.build(:body => body) do |post|
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
  
  def self.prefetch_from(records)
    find(:all, :select => 'distinct *', :conditions => ['id in (?)', records.collect(&:user_id).uniq])
  end
  
  def self.index_from(records)
    prefetch_from(records).index_by(&:id)
  end

protected
  def revise_topic(topic, attributes)
    topic.sticky, topic.locked = attributes[:sticky], attributes[:locked] if moderator?
    topic.save
  end
end