# frozen_string_literal: true

# Helper class to translate variant names to Active Storage variants
# and process them.
class ImageVariant
  S3_PUBLIC_ACL = 'public-read'
  VARIANTS = {
    tiny: [25, 25],
    small: [50, 50],
    large: [125, 125],
    album: [200, 200],
    original: [800, 800],
    greenfield: [1500, 1500],
    hq: [3000, 3000]
  }.freeze

  attr_reader :attachment
  attr_reader :variant_name

  def initialize(attachment, variant:)
    ImageVariant.verify(variant)

    @attachment = attachment
    @variant_name = variant
  end

  def process
    variant = to_active_storage_variant.processed
    put_s3_object_acl
    variant
  end

  def resize_to_limit
    ImageVariant.resize_to_limit(variant_name)
  end

  def to_active_storage_variant
    attachment.variant(resize_to_limit: resize_to_limit)
  end

  # Returns an Active Storage variant for a named variant.
  def self.variant(attachment, variant:)
    new(attachment, variant: variant).to_active_storage_variant
  end

  # Processes all variants for an attachment.
  def self.process(attachment)
    VARIANTS.keys.map do |variant_name|
      new(attachment, variant: variant_name).process
    end
  end

  # Fit a variant inside these dimensions (width x height) to generate the variant.
  def self.resize_to_limit(variant_name)
    VARIANTS[variant_name.to_sym]
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

  private

  def to_s3_object
    variant = to_active_storage_variant
    variant.service.send(:object_for, variant.key)
  rescue NoMethodError
    nil
  end

  def put_s3_object_acl
    # Image variants are expected to be publicly readable from from the bucket
    # so we have to change their ACL.
    if object_acl = to_s3_object&.acl
      object_acl.put(acl: S3_PUBLIC_ACL)
    end
  end
end
