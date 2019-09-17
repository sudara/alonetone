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
      if Rails.application.play_dummy_audio? || Rails.env.test?
        play_local_mp3
      else
        redirect_to asset.download_location.to_s
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
    sleep(2) unless Rails.env.test? # simulate network loading, it'll be 2x with range requests
    file_to_send = File.join(Rails.root, 'spec/fixtures/files/muppets.mp3')

    length = File.size(file_to_send) # need to do this manually for header to be set correctly

    # SHITTON OF HEADER HACKS TO APPEASE HTML5 locally :)
    file_begin = 0
    file_end = length - 1
    headers['Accept-Ranges'] = 'bytes'
    headers["Cache-Control"] = "public, must-revalidate, max-age= "
    headers["Pragma"] = "public"
    headers['Connection'] = 'close'
    headers['Content-Type'] = 'audio/mpeg'
    headers["Content-Length"] = length.to_s

    if !request.headers["Range"]
      status = "200 OK"
      send_file file_to_send, url_based_filename: true,
        status: status, stream: true, buffer_size: 4096
    else
      status = "206 Partial Content" # browser wants part of the file
      match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)
      if match
        file_begin = match[1].to_i
        file_end = match[2].to_i if match[2] && !match[2].empty?
      end
      headers["Content-Range"] = "bytes #{file_begin}-#{file_end}/#{length}"

      number_of_bytes = file_end - file_begin + 1

      # Safari expects to see 2 bytes when it asks for 0-1 as a range
      headers["Content-Length"] = number_of_bytes

      send_data File.read(file_to_send, number_of_bytes, file_begin), type: 'audio/mpeg',
        url_based_filename: true, status: status, stream: true, buffer_size: 4096
    end
  end
end
