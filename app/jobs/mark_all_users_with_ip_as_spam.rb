class MarkAllUsersWithIpAsSpam < ApplicationJob
  queue_as :default

  def perform(ip)
    return unless ip.present? # older acocunts have ip as nil

    User.where(current_login_ip: ip).each do |user|
      UserCommand.new(user).spam_soft_delete_with_relations
    end
  end
end
