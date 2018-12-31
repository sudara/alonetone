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
    @listens_pagy, @listens = pagy(@user.listens, page_param: :listens_page, items: 10)
    @track_plays_pagy, @track_plays = pagy(@user.track_plays, page_param: :track_plays_page, items: 10)
  end
end
