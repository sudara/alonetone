class SettingsController < ApplicationController
  before_action :require_login, :find_user

  def update
    flush_asset_cache_if_necessary
    @user.settings.toggle! settings_params
  end

  private

  # If the user changes the :block_guest_comments setting then it requires
  # that the cache for all their tracks be invalidated
  def flush_asset_cache_if_necessary
    if settings_params.keys.include(:block_guest_comments)
      Asset.where(user_id: @user.id).touch_all
    end
  end

  def settings_params
    params[:settings].permit(:display_listen_count,
      :block_guest_comments,
      :most_popular,
      :increase_ego,
      :email_comments,
      :email_new_tracks)
  end
end
