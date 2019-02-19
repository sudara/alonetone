# frozen_string_literal: true

# Helper class to translate between variant names and dimensions.
class ImageVariant
  VARIANTS = {
    tiny: [25, 25],
    small: [50, 50],
    large: [125, 125],
    album: [200, 200],
    original: [800, 800],
    greenfield: [1500, 1500],
    hq: [3000, 3000]
  }

  # Fit a variant inside these dimensions (width x height) to generate the variant.
  def self.resize_to_fit(variant_name)
    VARIANTS[variant_name.to_sym]
  end

  # Raises ArgumentError with explanation when the variant name does not exist.
  def self.verify(variant_name)
    unless ImageVariant::VARIANTS.has_key?(variant_name.to_sym)
      raise(
        ArgumentError,
        "Unknown variant: `#{variant_name.inspect}', please use: #{variants_as_sentence}"
      )
    end
  end

  # Returns an English sentence with all the variant options.
  def self.variants_as_sentence
    VARIANTS.keys.to_sentence(
      two_words_connector: ' or ',
      last_word_connector: ', or ',
      locale: :en
    )
  end
end
