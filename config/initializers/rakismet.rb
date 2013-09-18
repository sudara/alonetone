if Alonetone.rakismet_key
  RAKISMET_ENABLED = true
  Alonetone::Application.config.rakismet.key = Alonetone.rakismet_key
  Alonetone::Application.config.rakismet.url = Alonetone.url
else
  RAKISMET_ENABLED = false
end