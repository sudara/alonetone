# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminFormBuilder, type: :helper do
  it 'renders a field div for an attribute without errors' do
    record = User.new
    html = form_for(record, builder: AdminFormBuilder) do |form|
      form.field :login do
        form.label_with_error :login
      end
    end
    expect(html).to match_css('form > div.field > label[for="user_login"]')
  end

  it 'renders a field div for an attribute with an error' do
    record = User.new
    record.errors.add(:login, :blank)
    html = form_for(record, builder: AdminFormBuilder) do |form|
      form.field :login do
        form.label_with_error :login
      end
    end
    expect(html).to match_css('form > div.field.invalid label[for="user_login"]')
  end
end
