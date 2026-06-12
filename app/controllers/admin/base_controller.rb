module Admin
  class BaseController < ApplicationController
    include Admin::Range

    layout 'admin'
    before_action :moderator_only

    private

    def admin_row_request?
      params[:row].to_s == 'true'
    end

    def turbo_stream_row_request?
      request.format.turbo_stream? && admin_row_request?
    end
  end
end
