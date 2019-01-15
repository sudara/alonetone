module Listens
  extend ActiveSupport::Concern
  include PreventAbuse

  def create_listen
    register_listen(find_asset)
    render nothing: true
  end

  private

  def cloudfront_url(url, expires_in = 20.minutes)
    Aws::CF::Signer.sign_url url, expires: Time.now + expires_in
  end

  def listen(asset, register: true)
    unless prevent_abuse(asset)
      register_listen(asset) if register
      if Alonetone.try(:play_dummy_mp3s)
        play_local_mp3
      elsif Alonetone.try(:cloudfront_enabled)
        redirect_to cloudfront_url(asset.mp3.url)
      else
        redirect_to asset.mp3.expiring_url
      end
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

  def play_local_mp3
    file_to_send = File.join(Rails.root, 'spec/fixtures/files/muppets.mp3')

    length = File.size(file_to_send) # need to do this manually for header to be set correctly

    # SHITTON OF HEADER HACKS TO APPEASE HTML5 locally :)
    file_begin = 0
    file_end = length - 1
    headers['Accept-Ranges'] = 'bytes'
    headers["Cache-Control"] = "public, must-revalidate, max-age=0"
    headers["Pragma"] = "no-cache"
    headers['Connection'] = 'close'
    if !request.headers["Range"] || (request.headers["Range"] == "bytes=0-") # browser wants the whole file
      status = "200 OK"
      headers["Content-Length"] = (file_end.to_i - file_begin.to_i + 1).to_s

      send_file file_to_send, type: 'audio/mpeg', disposition: 'attachment;',
                              url_based_filename: true, status: status, stream: true, buffer_size: 4096
    else
      status = "206 Partial Content" # browser wants part of the file
      match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)
      if match
        file_begin = match[1]
        file_end = match[2] if match[2] && !match[2].empty?
      end
      headers["Content-Range"] = "bytes " + file_begin.to_s + "-" + file_end.to_s + "/" + length.to_s
      headers["Content-Length"] = (file_end.to_i - file_begin.to_i + 1).to_s
      how_many_bytes = file_end.to_i - file_begin.to_i > 0 ? file_end.to_i - file_begin.to_i : 1
      send_data File.read(file_to_send, how_many_bytes, file_begin.to_i), type: 'audio/mpeg', disposition: 'attachment;',
                                                                          url_based_filename: true, status: status, stream: true, buffer_size: 4096
    end
  end
end
