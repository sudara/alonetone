# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  protected

  delegate :hostname, to: 'Rails.configuration.alonetone'
end
