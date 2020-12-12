Rails.application.config.session_store :cookie_store,
  key: 'alonetone',
  secure: Rails.env.production?,
  expire_after: 30.days