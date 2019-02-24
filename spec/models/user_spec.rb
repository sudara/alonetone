require "rails_helper"

RSpec.describe User, type: :model do
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

    it "should not require a profile on update" do
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
    let(:user) { users(:sudara) }
    let!(:asset) { assets(:valid_mp3) }
    let!(:topic) { topics(:topic1) }
    let!(:playlist) { playlists(:owp) }
    let!(:comment) { comments(:valid_comment_on_asset_by_user) }
    let!(:listen) { listens(:valid_listen) }

    describe "soft delete" do
      it "should mark assets as soft deleted" do
        user.destroy(recursive: true)

        expect(user.reload.deleted_at).not_to be_nil
        expect(asset.reload.deleted_at).not_to be_nil
      end

      it "doesnt delete other associated records (listens tracks playlists posts topics comments)" do
        user.destroy(recursive: true)

        expect(user.listens).to be_present
        expect(user.tracks).to be_present
        expect(user.playlists).to be_present
        expect(user.topics).to be_present
        expect(user.comments).to be_present
      end
    end

    describe "really delete" do
      it "should really destroy all associated assets" do
        user.really_destroy!

        expect(User.where(id: user.id)).not_to be_present
        expect(Asset.where(user_id: user.id)).not_to be_present
      end

      it 'should remove listens tracks playlists posts topics comments assets as well' do
        user.really_destroy!

        expect(Listen.where(track_owner_id: user.id)).not_to be_present
        expect(Track.where(user_id: user.id)).not_to be_present
        expect(Playlist.where(user_id: user.id)).not_to be_present
        expect(Topic.where(user_id: user.id)).not_to be_present
        expect(Comment.where(commenter_id: user.id)).not_to be_present
      end
    end
  end

  protected

  def new_user(options = {})
    User.new({ email: 'new@user.com', login: 'newuser', password: 'quire451', password_confirmation: 'quire451' }.merge(options))
  end
end
