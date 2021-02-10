# frozen_string_literal: true

module Admin
  class MassInvitesController < Admin::BaseController
    def index
      @pagy, @mass_invites = pagy(filtered_mass_invites)
    end

    def new
      @mass_invite = MassInvite.new
    end

    def create
      @mass_invite = MassInvite.new(mass_invite_params)
      if @mass_invite.save
        redirect_to admin_mass_invites_url(filter_by: 'active')
      else
        render :new
      end
    end

    def update
      MassInvite.where(token: params[:token]).update_all(**mass_invite_params)
      redirect_to admin_mass_invites_url(filter_by: 'active')
    end

    private

    def mass_invite_params
      params.require(:mass_invite).permit(:name, :token, :archived)
    end

    def filtered_mass_invites
      MassInvite.recent.where(archived: params[:filter_by] == 'archived')
    end
  end
end
