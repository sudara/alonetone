class AdminConstraint
  def matches?(request)
    credentials = request.cookie_jar['user_credentials']
    return false unless credentials.present?

    User.find_by(persistence_token: credentials.split(':')[0]).try(:admin?)
  end
end
