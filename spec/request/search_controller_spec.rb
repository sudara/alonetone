require "rails_helper"

RSpec.describe SearchController, type: :request do
  it "searches assets by name / filename and returns results" do
    get search_query_path("Song1")

    expect(response).to be_successful
    expect(response.body).to include(assets(:valid_mp3).title)
  end

  it "does not return results when search term is empty" do
    post "/search"

    expect(response).to be_successful
    expect(response.body).to include("Search artists and uploads")
    expect(response.body).not_to include("Tracks that match")
  end

  it "does not return results for a soft-deleted asset with a soft-deleted user" do
    asset = assets(:another_valid_asset_to_test_on_latest)
    get search_query_path(asset.title.to_s)
    expect(response.body).to include(%(Tracks that match "#{asset.title}"))

    UserCommand.new(asset.user).soft_delete_with_relations

    get search_query_path(asset.title.to_s)
    expect(response.body).not_to include(%(Tracks that match "#{asset.title}"))
  end
end
