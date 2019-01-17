require "rails_helper"

RSpec.describe AlbumNotification, type: :mailer do
  describe "album_release" do
    let(:mail) { AlbumNotification.album_release(playlists(:owp), users(:sudara).email) }

    it "renders the headers" do
      expect(mail.subject).to eq("[alonetone] '#{users(:sudara).name}' released a new album!")
      expect(mail.to).to eq(["#{users(:sudara).email}"])
      expect(mail.from).to eq(["#{Alonetone.email}"])
    end

    it "includes the unfollow link" do
      expect(mail.body).to include("https://#{Alonetone.url}/unfollow/#{users(:sudara).login}")
    end

    it "includes the unsubscribe link" do
      expect(mail.body).to include("https://#{Alonetone.url}/notifications/unsubscribe")
    end
  end
end
