# -*- encoding : utf-8 -*-
module User::Editable
  def editable_by?(user)
    user && (user.id == user_id || user.moderator? || user.admin?)
  end
end
