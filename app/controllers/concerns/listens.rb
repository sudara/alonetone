module Listens
  extend ActiveSupport::Concern
  include PreventAbuse

  def create_listen
    register_listen(find_asset)
    render nothing: true
  end

  private

  def listen(asset, register: true)
    unless prevent_abuse(asset)
      register_listen(asset) if register
      sleep(1) if Rails.env.development? # simulate network loading, it'll be 2x with range requests
      redirect_to asset.download_location.to_s, allow_other_host: true
    end
  end

  def listen_referer
    case params[:referer]
    when 'itunes' then 'itunes'
    else request.env['HTTP_REFERER']
    end
  end

  def prevent_abuse(asset)
    if is_a_bot?
      Rails.logger.error "BOT LISTEN ATTEMPT FAIL: #{asset.mp3_file_name} #{user_agent} #{request.remote_ip} #{listen_referer} User:#{current_user || 0}"
      render plain: "Denied due to abuse", status: 403
    end
  end

  def register_listen(asset)
    unless is_a_bot? || ip_just_registered_this_listen?(asset)
      asset.listens.create(
        listener: current_user || nil,
        track_owner: asset.user,
        source: listen_referer,
        user_agent: user_agent,
        ip: request.remote_ip,
        city: request.headers["HTTP_GEOIP_CITY"], # set by nginx geoip
        country: request.headers["HTTP_GEOIP_COUNTRY_CODE"]
      )
    end
  end

  def ip_just_registered_this_listen?(asset)
    last_listen = asset.listens.since(1.week.ago).where(ip: request.remote_ip).first
    last_listen.present? && (last_listen.created_at > (Time.now - asset[:length]))
  end
end
