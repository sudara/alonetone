# dartsass-rails compiles app/assets/stylesheets/*.scss into app/assets/builds/.
# Without excluding the sources, Propshaft fingerprints and ships the raw .scss
# alongside the built CSS — harmless but bloats the deploy.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
