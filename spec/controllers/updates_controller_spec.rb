require "rails_helper"

RSpec.describe UpdatesController, type: :controller do

  fixtures :users, :updates

  it 'should allow anyone to view the updates index' do
    get :index
    expect(response).to be_success
  end

  it "should not allow a normal user to edit an update" do
    login users(:arthur)
    get :edit, :id => updates(:valid)
    expect(response).not_to be_success
  end

  it 'should not let a guest edit an update' do
    get :edit, :id => updates(:valid)
    expect(response).not_to be_success
  end

  it 'should not let a guest update or destroy an update' do
    put :update, :id => updates(:valid), :title => 'change me'
    expect(response).not_to be_success
  end

  it "should allow an admin to edit a blog entry" do
    login users(:sudara)
    allow(controller).to receive(:current_user).and_return(users(:sudara))
    get :edit, :id => updates(:valid).permalink
    expect(controller.session["user_credentials"]).to eq(users(:sudara).persistence_token)
    expect(response).to be_success
  end

  it "should allow an admin to update a blog entry" do
    login users(:sudara)
    allow(controller).to receive(:current_user).and_return(users(:sudara))
    put :update, :id => updates(:valid).permalink, :title => 'change me'
    expect(response).to redirect_to(update_path(updates(:valid).permalink))
  end

  it "should not let a normal joe create a blog entry" do
    post :create, :title => 'new', :content => 'report'
    expect(response).not_to be_success
  end
end
