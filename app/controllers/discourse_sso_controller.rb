# This is one of the few things in alonetone that is production-only
require 'single_sign_on'

class DiscourseSsoController < ApplicationController
  before_action :require_login

  def sso
    secret = Rails.configuration.alonetone.discourse_secret
    sso = SingleSignOn.parse(request.query_string, secret)
    sso.email = current_user.email
    sso.name = current_user.display_name
    sso.username = current_user.login
    sso.external_id = current_user.id
    sso.sso_secret = secret
    sso.bio = current_user.profile.bio
    sso.moderator = current_user.moderator?
    sso.admin = current_user.admin?
    sso.avatar_url = current_user.avatar_image_location(variant: :large_avatar).to_s

    redirect_to sso.to_url(Rails.configuration.alonetone.discourse_url)
  end
end
