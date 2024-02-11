class LoginIsAllowedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if !login_is_unique(value)
      record.errors.add(attribute, :login_not_unique)
    end

    if !login_is_allowed(value)
      record.errors.add(attribute, :login_not_allowed)
    end
  end
  
  def login_is_allowed(login)
    return !login_contains_reserved_words(login) && !login_contains_route_part(login)
  end
  
  def login_is_unique(login)
    if User.where(login: login).exists?
      return false
    end

    if AccountRequest.where(login: login).exists?
      return false
    end

    true
  end

  def login_contains_reserved_words(login)
    ReservedWord.find_each.any? { |rw| rw.contains(login) }
  end

  def login_contains_route_part(login)
    Rails.application.routes.routes.any? {|route|
      route = route.path.spec.to_s
      route.split(/[^\w]/).reject(&:empty?).any? { |part| login == part }
    }
  end
end