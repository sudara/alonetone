require "rails_helper"

RSpec.describe AssetNotification, type: :mailer do
  describe "upload_notification" do
    let(:mail) { AssetNotification.upload_notification(assets(:valid_mp3), users(:sudara).email) }

    it "renders the headers" do
      expect(mail.subject).to eq("[alonetone] '#{assets(:valid_mp3).user.name}' uploaded a new track!")
      expect(mail.to).to eq(["#{users(:sudara).email}"])
      expect(mail.from).to eq(["#{Rails.configuration.alonetone.email}"])
    end

    it "includes the unfollow link" do
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/unfollow/#{assets(:valid_mp3).user.login}")
    end

    it "includes the unsubscribe link" do
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/notifications/unsubscribe")
    end
  end
end
