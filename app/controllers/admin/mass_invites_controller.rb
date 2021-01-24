# frozen_string_literal: true

module Admin
  class MassInvitesController < Admin::BaseController
    def index
      @pagy, @mass_invites = pagy(MassInvite.recent)
    end

    def new
      @mass_invite = MassInvite.new
    end

    def create
      @mass_invite = MassInvite.new(mass_invite_params)
      if @mass_invite.save
        redirect_to admin_mass_invites_url
      else
        render :new
      end
    end

    private

    def mass_invite_params
      params.require(:mass_invite).permit(:name, :token)
    end
  end
end
