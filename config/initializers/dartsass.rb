Rails.application.config.dartsass.builds = {
  "application.scss"   => "application.css",
  "dark_theme.scss"    => "dark_theme.css",
  "blog.scss"          => "blog.css",
  "rpm_challenge.scss" => "rpm_challenge.css",
  "24houralbum.scss"   => "24houralbum.css",
  "ipad.scss"          => "ipad.css"
}

# Theme stylesheets still rely on legacy global imports. Keep asset builds clean
# until the theme variables can move to Sass modules without changing CSS output.
Rails.application.config.dartsass.build_options << "--silence-deprecation=import"
