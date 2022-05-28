# frozen_string_literal: true

# Uses the License model to validate a license code value and make sure it's supported.
#
#   validates :license_code, license_code: true
class LicenseCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.present? && License.new(value).supported?

    record.errors.add(attribute, :invalid_license_code, license_code: value)
  end
end
