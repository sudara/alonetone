require "rails_helper"

RSpec.describe CommentNotification, type: :mailer do
  describe "new_comment by user" do
    let(:asset) { assets(:valid_mp3) }
    let(:comment) { comments(:valid_comment_on_asset_by_user) }
    let(:mail) { CommentNotification.new_comment(comment, asset)}

    it "renders the headers" do
      expect(mail.to).to eq(["sudara@modernthings.net"])
      expect(mail.from).to eq(["#{Rails.configuration.alonetone.email}"])
      expect(mail.subject).to eq("[alonetone] Comment on '#{asset.name}' from sudara")
    end

    it "renders the body" do
      expect(mail.body).to include("Hey there sudara")
      expect(mail.body).to include("sudara says:")
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/sudara/edit")
    end

    it "includes the unsubscribe link" do
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/notifications/unsubscribe")
    end
  end

  describe "new_comment by guest" do
    let(:asset) { assets(:valid_mp3) }
    let(:comment) { comments(:valid_comment_on_asset_by_guest) }
    let(:mail) { CommentNotification.new_comment(comment, asset)}

    it "renders the headers" do
      expect(mail.to).to eq(["sudara@modernthings.net"])
      expect(mail.from).to eq(["#{Rails.configuration.alonetone.email}"])
      expect(mail.subject).to eq("[alonetone] Comment on '#{asset.name}' from Guest")
    end

    it "renders the body" do
      expect(mail.body).to include("Hey there sudara")
      expect(mail.body).to include("Guest says:")
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/sudara/edit")
    end

    it "includes the unsubscribe link" do
      expect(mail.body).to include("https://#{Rails.configuration.alonetone.hostname}/notifications/unsubscribe")
    end
  end
end
