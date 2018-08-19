# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# We need to pull css out of webpack modules
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w(soundmanager2.swf soundmanager2_flash9.swf ipad.css 24houralbum.css rpm_challenge.css blog.css white_theme.css white_theme_thredded.css white_theme.js)
