# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  login               :string(40)
#  email               :string(100)
#  salt                :string(128)      default(""), not null
#  activated_at        :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  admin               :boolean          default(FALSE)
#  last_login_at       :datetime
#  crypted_password    :string(128)      default(""), not null
#  assets_count        :integer          default(0), not null
#  display_name        :string(255)
#  playlists_count     :integer          default(0), not null
#  website             :string(255)
#  bio                 :text(16777215)
#  listens_count       :integer          default(0)
#  itunes              :string(255)
#  comments_count      :integer          default(0)
#  last_login_ip       :string(255)
#  country             :string(255)
#  city                :string(255)
#  settings            :text(16777215)
#  lat                 :float(24)
#  lng                 :float(24)
#  bio_html            :text(16777215)
#  posts_count         :integer          default(0)
#  moderator           :boolean          default(FALSE)
#  browser             :string(255)
#  twitter             :string(255)
#  followers_count     :integer          default(0)
#  login_count         :integer          default(0), not null
#  current_login_at    :datetime
#  current_login_ip    :string(255)
#  persistence_token   :string(255)
#  perishable_token    :string(255)
#  last_request_at     :datetime
#  bandwidth_used      :integer          default(0)
#  greenfield_enabled  :boolean          default(FALSE)
#  white_theme_enabled :boolean          default(FALSE)
#

require "rails_helper"

RSpec.describe User, type: :model do
  fixtures :users, :assets, :playlists, :tracks

  context "validation" do
    it "should be valid with email, login and password" do
      expect(new_user).to be_valid
      expect(users(:sudara)).to be_valid
    end

    it "can be an admin" do
      expect(users(:sudara)).to be_admin
    end

    it "can be a mod" do
      expect(users(:sandbags)).to be_moderator
    end

    it "should not require a bio on update" do
      @user = new_user
      @user.save
      @user.save
      expect(@user).to be_valid
    end
  end

  context "activation" do
    it "is considered active when persishble token doesn't exist" do
      expect(users(:arthur)).to be_active
    end

    it "is not active when perishable token exists" do
      expect(users(:not_activated).perishable_token).to be_present
      expect(users(:not_activated)).not_to be_active
    end

    it "can be activated and deactivated" do
      users(:not_activated).activate!
      expect(users(:not_activated)).to be_active
      users(:not_activated).reset_perishable_token!
      expect(users(:not_activated)).not_to be_active
    end
  end

  context "relations" do
    it 'has tracks called assets' do
      expect(users(:arthur).assets).to be_present
    end

    it 'has a favorites playlist and tracks' do
      # users(:arthur).favorites.should be_present
    end
  end

  context "deletion" do
    it 'should remove listens tracks playlists posts topics comments assets as well' do
    end
  end

  protected

  def new_user(options = {})
    User.new({ email: 'new@user.com', login: 'newuser', password: 'quire451', password_confirmation: 'quire451' }.merge(options))
  end
end
