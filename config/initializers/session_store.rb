Rails.application.config.session_store :cookie_store,
  key: 'alonetone',
  secure: Rails.env.production?,
  same_site: :lax,
  expire_after: 30.days