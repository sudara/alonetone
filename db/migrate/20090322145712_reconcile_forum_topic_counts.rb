class ReconcileForumTopicCounts < ActiveRecord::Migration
  def self.up
    Forum.all.each do |forum|
      Forum.update_all "topics_count = #{forum.topics.count}", ['id = ?', forum.id]
    end
  end

  def self.down
  end
end
