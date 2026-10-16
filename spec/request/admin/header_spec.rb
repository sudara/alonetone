require 'rails_helper'

RSpec.describe 'Admin header', type: :request do
  before { create_user_session(users(:sudara)) }

  def h1_text(body)
    Nokogiri::HTML(body).at_css('header h1').text.strip
  end

  it 'shows the category name on a track sub-page, not the sub-page label' do
    get admin_most_played_path
    expect(h1_text(response.body)).to eq('Tracks')
    # the sub-page is still identifiable via the view tabs
    expect(response.body).to include('Most Played')
  end

  it 'keeps the category name across every track view' do
    [admin_assets_path, admin_most_played_path, admin_all_time_path].each do |path|
      get path
      expect(h1_text(response.body)).to eq('Tracks')
    end
  end

  it 'shows the category name on user sub-pages' do
    [admin_users_path, admin_shared_ips_path, admin_bandwidth_path].each do |path|
      get path
      expect(h1_text(response.body)).to eq('Users')
    end
  end

  it 'shows the category name on a user detail page while the name stays in the body' do
    user = users(:arthur)
    get admin_possibly_deleted_user_path(user)
    expect(h1_text(response.body)).to eq('Users')
    expect(response.body).to include(user.name)
  end

  it 'still titles the browser tab with the specific sub-page' do
    get admin_most_played_path
    expect(Nokogiri::HTML(response.body).at_css('title').text).to include('Most Played')
  end

  {
    admin_path: 'Dashboard',
    admin_account_requests_path: 'Account Requests',
    admin_mass_invites_path: 'Mass Invites',
    admin_users_path: 'Users',
    admin_assets_path: 'Tracks',
    admin_comments_path: 'Comments',
    admin_listens_path: 'Listens',
    admin_devops_path: 'Devops'
  }.each do |path_helper, category|
    it "shows '#{category}' as the heading for #{path_helper}" do
      get public_send(path_helper)
      expect(h1_text(response.body)).to eq(category)
    end
  end

  it 'falls back to the category on a sub-page that is not its own nav entry' do
    get new_admin_mass_invite_path
    expect(h1_text(response.body)).to eq('Mass Invites')
  end
end
