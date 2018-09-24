class ListensController < ApplicationController
  include Listens

  before_action :find_user, only: [:index]
  before_action :find_listen_history, only: [:index]

  def index; end

  def create
    @asset = Asset.find(params[:id])
    register_listen(@asset)
    head :ok
  end

  protected

  def find_listen_history
    @listens = @user.listens.paginate(
      per_page: 10,
      page: params[:listens_page]
    )
    @track_plays = @user.track_plays.paginate(
      per_page: 10,
      page: params[:track_plays_page]
    )
  end
end
