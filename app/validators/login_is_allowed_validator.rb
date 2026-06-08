class LoginIsAllowedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, :login_not_unique) unless login_is_unique?(record, value)
    record.errors.add(attribute, :login_not_allowed) unless login_is_allowed?(value)
  end

  private

  def login_is_unique?(record, login)
    !other_user_has_login?(record, login) && !pending_request_reserves_login?(record, login)
  end

  def other_user_has_login?(record, login)
    scope = User.where(login: login)
    scope = scope.where.not(id: record.id) if record.is_a?(User) && record.persisted?
    scope.exists?
  end

  # A user is created from an approved account request that shares its login, so a
  # request only reserves a login while waiting, and only against other requests.
  def pending_request_reserves_login?(record, login)
    return false if record.is_a?(User)

    scope = AccountRequest.waiting.where(login: login)
    scope = scope.where.not(id: record.id) if record.is_a?(AccountRequest) && record.persisted?
    scope.exists?
  end

  def login_is_allowed?(login)
    !login_contains_reserved_word?(login) && !login_matches_route_segment?(login)
  end

  def login_contains_reserved_word?(login)
    ReservedWord.find_each.any? { |reserved_word| reserved_word.contains(login) }
  end

  def login_matches_route_segment?(login)
    self.class.route_segments.include?(login)
  end

  def self.route_segments
    @route_segments ||= Rails.application.routes.routes.flat_map { |route|
      route.path.spec.to_s.split(/[^\w]/)
    }.reject(&:empty?).to_set
  end
end
