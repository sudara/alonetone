# frozen_string_literal: true

# Helper class to translate variant names to Active Storage transformation.
class ImageVariant
  VARIANTS = {
    tiny: 25,
    small: 50,
    large: 125,
    album: 200,
    original: 800,
    greenfield: 1500,
    hq: 3000
  }.freeze

  attr_reader :attachment
  attr_reader :variant_name

  def initialize(attachment, variant:)
    ImageVariant.verify(variant)

    @attachment = attachment
    @variant_name = variant
  end

  def variant_options
    ImageVariant.variant_options(variant_name)
  end

  def to_active_storage_variant
    attachment.variant(**variant_options)
  end

  # Returns an Active Storage variant for a named variant.
  def self.variant(attachment, variant:)
    new(attachment, variant: variant).to_active_storage_variant
  end

  # Returns options to pass to VIPS to generate a variant of the original file.
  def self.variant_options(variant_name)
    size = VARIANTS[variant_name.to_sym]
    {
      resize_to_fill: [size, size, crop: :centre],
      saver: { quality: 68, optimize_coding: true, strip: true }
    }
  end

  # Raises ArgumentError with explanation when the variant name does not exist.
  def self.verify(variant_name)
    unless ImageVariant::VARIANTS.key?(variant_name.to_sym)
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
