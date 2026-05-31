class RefreshForumTopicsJob < ApplicationJob
  queue_as :default

  def perform
    ForumTopics.refresh!
  end
end
