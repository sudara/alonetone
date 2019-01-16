# frozen_string_literal: true

require 'rails_helper'

# NOTE: this is a slightly weird spec but it's useful when working on the
# implementation to have something that automatically does a sanity check
# against the Configurable mixin.
RSpec.describe Configurable do
  it "defines accessors for all configuration keys" do
    Configurable::ATTRIBUTES.each do |method_name|
      expect(Alonetone).to respond_to(method_name)
    end
  end
end
