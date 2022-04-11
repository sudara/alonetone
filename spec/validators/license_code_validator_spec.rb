# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LicenseCodeValidator do
  class LicenseCodeValidatorModel
    include ActiveModel::Validations

    attr_reader :license_code

    def initialize(license_code)
      @license_code = license_code
    end

    validates :license_code, license_code: true
  end

  it 'allows valid license code' do
    record = LicenseCodeValidatorModel.new('by/4.0')
    expect(record).to be_valid
  end

  it 'disallow nil' do
    record = LicenseCodeValidatorModel.new(nil)
    expect(record).to_not be_valid
  end

  it 'disallows empty value' do
    record = LicenseCodeValidatorModel.new('')
    expect(record).to_not be_valid
  end

  it 'disallows invalid record' do
    record = LicenseCodeValidatorModel.new('unknown')
    expect(record).to_not be_valid
    expect(record.errors.details).to eq(
      license_code: [
        {
          error: :invalid_license_code,
          license_code: 'unknown'
        }
      ]
    )
  end
end
