# frozen_string_literal: true

require 'rails_helper'

# Two representative partials covering the id/class wrapper pattern that
# used to come from the removed `div_for` / `content_tag_for` helpers.
RSpec.describe "wrapper partials", type: :view do
  def wrapper(selector)
    Capybara::Node::Simple.new(rendered).find(selector)
  end

  it "shared/_playlist wraps the playlist with dom_id, data-id, and 'playlist small_playlists' classes" do
    playlist = playlists(:owp)
    assign(:user, nil)

    render partial: "shared/playlist", locals: { playlist: playlist }

    li = wrapper("li##{dom_id(playlist)}")
    expect(li[:class].split).to include("playlist", "small_playlists")
    expect(li["data-id"]).to eq(playlist.id.to_s)
  end

  it "shared/_user wraps the user with dom_id and class 'user user_index'" do
    user = users(:sudara)
    without_partial_double_verification do
      allow(view).to receive_messages(admin?: false, current_user: nil, logged_in?: false)
    end

    render partial: "shared/user", locals: { user: user }

    div = wrapper("div##{dom_id(user)}")
    expect(div[:class].split).to contain_exactly("user", "user_index")
  end
end
