# frozen_string_literal: true

# Validates one or more attached records to make sure they adhere to certain
# conditions.
#
#   validates :original, attached: {
#     content_type: %w(audio/mpeg audio/mp3 audio/x-mp3),
#     byte_size: { less_than: 60.megabytes }
#   }
class AttachedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    validate_content_type(record, attribute, value) if options.key?(:content_type)
    validate_byte_size(record, attribute, value) if options.key?(:byte_size)
  end

  private

  def validate_content_type(record, attribute, value)
    content_type = value.content_type
    unless accepted_content_types.include?(content_type)
      record.errors.add(
        attribute, :invalid_content_type,
        value: content_type,
        accepted: accepted_content_types,
        accepted_sentence: accepted_content_types.to_sentence
      )
    end
  end

  def validate_byte_size(record, attribute, value)
    byte_size = value.byte_size
    if byte_size.zero?
      record.errors.add(attribute, :blank, value: byte_size) unless allow_empty?
      return
    end

    validate_byte_size_greater_than(record, attribute, byte_size)
    validate_byte_size_less_than(record, attribute, byte_size)
  end

  def validate_byte_size_greater_than(record, attribute, byte_size)
    if greater_than && (byte_size <= greater_than)
      record.errors.add(
        attribute, :byte_size_too_small,
        value: byte_size,
        greater_than: greater_than,
        greater_than_human_size: ActiveSupport::NumberHelper.number_to_human_size(greater_than)
      )
    end
  end

  def validate_byte_size_less_than(record, attribute, byte_size)
    if less_than && (byte_size >= less_than)
      record.errors.add(
        attribute, :byte_size_too_large,
        value: byte_size,
        less_than: less_than,
        less_than_human_size: ActiveSupport::NumberHelper.number_to_human_size(less_than)
      )
    end
  end

  def accepted_content_types
    [options[:content_type]].flatten
  end

  def greater_than
    options.dig(:byte_size, :greater_than)
  end

  def less_than
    options.dig(:byte_size, :less_than)
  end

  def allow_empty?
    options.dig(:byte_size, :allow_empty) || false
  end
end
