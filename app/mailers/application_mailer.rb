# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.alonetone.email

  delegate :hostname, to: 'Rails.configuration.alonetone'
end
