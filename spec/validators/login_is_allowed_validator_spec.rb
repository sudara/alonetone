# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoginIsAllowedValidator do
    class LoginIsAllowedValidatorModel
        include ActiveModel::Validations

        attr_reader :login
    
        def initialize(login)
          @login = login
        end
    
        validates :login, login_is_allowed: true
    end

    it 'allows nil' do
      record = LoginIsAllowedValidatorModel.new(nil)
      expect(record).to be_valid
    end

    it 'allows empty' do
      record = LoginIsAllowedValidatorModel.new('')
      expect(record).to be_valid
    end

    it 'disallows duplicate user logins' do
      record = LoginIsAllowedValidatorModel.new('williamshatner')
      expect(record).to_not be_valid
      expect(record.errors.details).to eq(
        login: [
          {
            error: :login_not_unique
          }
        ]
    )
    end

    it 'disallows duplicate account request (waiting) logins' do
      record = LoginIsAllowedValidatorModel.new('newband')
      expect(record).to_not be_valid
      expect(record.errors.details).to eq(
        login: [
          {
            error: :login_not_unique
          }
        ]
    )
    end

    it 'disallows reserved words' do
      record = LoginIsAllowedValidatorModel.new('petaQ')
      expect(record).to_not be_valid
      expect(record.errors.details).to eq(
        login: [
          {
            error: :login_not_allowed
          }
        ]
    )
    end

    it 'disallows names used by application routes' do
      ['admin', 'format', 'user_id', 'rails'].each do |login|
        record = LoginIsAllowedValidatorModel.new(login)
        expect(record).to_not be_valid
        expect(record.errors.details).to eq(
          login: [
            {
              error: :login_not_allowed
            }
          ]
        )
      end
    end
end