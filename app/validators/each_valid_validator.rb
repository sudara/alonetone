# frozen_string_literal: true

# Validates array of records to see if they are all valid. This operates comparable to
# `validates_associated' in Active Record.
#
#   validates :files, each_valid: true
class EachValidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?

    invalid_count = value.map(&:valid?).inject(0) { |count, valid| count + (valid ? 0 : 1) }
    if invalid_count > 0
      record.errors.add(
        attribute,
        :invalid,
        options.merge(invalid_count: invalid_count)
      )
    end
  end
end
