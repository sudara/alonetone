# -*- encoding : utf-8 -*-
class UserSession < Authlogic::Session::Base
  
  login_field :login
end
