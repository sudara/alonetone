# frozen_string_literal: true

# Helper class to generate slugs out of names or titles.
class Slug
  CONTROL_CHARACTERS_RE = /[\x00-\x1F\x7F]/

  def self.generate(string)
    raise(
      ArgumentError,
      "Can't generate a slug from a nil value."
    ) if string.nil?

    string.unicode_normalize.downcase(:fold).
      gsub(CONTROL_CHARACTERS_RE, '').
      gsub(%r{\A([[:space:]]+)}, '').
      gsub(%r{([[:space:]]+)\Z}, '').
      gsub(%r{[[:space:]]+}, '-')
  end
end
