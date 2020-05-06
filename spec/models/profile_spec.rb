require "rails_helper"

RSpec.describe Profile, type: :model do
  it "gets created with a user" do
    expect do
      User.create(email: 'new@user.com', login: 'newuser', password: 'quire451', password_confirmation: 'quire451')
    end.to change { Profile.count }
  end

  it "sanitizes website to remove http://" do
    henri = users(:henri_willig)
    henri.profile.update(website: 'http://my.site')
    expect(henri.profile.website).to eql('my.site')
  end

  it "sanitizes website to remove https://" do
    henri = users(:henri_willig)
    henri.profile.update(website: 'https://my.site')
    expect(henri.profile.website).to eql('my.site')
  end
end
