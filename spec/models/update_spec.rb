# == Schema Information
#
# Table name: updates
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  content      :text(65535)
#  created_at   :datetime
#  updated_at   :datetime
#  revision     :integer
#  content_html :text(65535)
#  permalink    :string(255)
#

require "rails_helper"

RSpec.describe Update, type: :model do
  fixtures :updates

  before(:each) do
    #@update = Update.new
  end

  it "should be valid and saveable" do
    expect(updates(:valid)).to be_valid
    expect(updates(:valid).save).to eq(true)
  end
end
