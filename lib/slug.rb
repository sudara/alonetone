# frozen_string_literal: true

# Helper class to generate slugs out of names or titles.
class Slug
  CONTROL_CHARACTERS_RE = /[\x00-\x1F\x7F]/

  def self.generate(string)
    raise(
      ArgumentError,
      "Can't generate a slug from a nil value."
    ) if string.nil?

    string.unicode_normalize.downcase(:fold)
          .gsub(CONTROL_CHARACTERS_RE, '')
          .gsub(%r{\A([[:space:]]+)}, '')
          .gsub(%r{([[:space:]]+)\Z}, '')
          .gsub(%r{[[:space:]]+}, '-')
  end

  DEDUPED_RE = %r{\A(.*)-(\d+)\Z}

  def self.increment(slug)
    if match = DEDUPED_RE.match(slug)
      "#{match[1]}-#{match[2].to_i + 1}"
    else
      "#{slug}-2"
    end
  end
end
