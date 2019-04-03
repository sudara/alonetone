module Listens
  extend ActiveSupport::Concern
  include PreventAbuse

  def create_listen
    register_listen(find_asset)
    render nothing: true
  end

  def self.cloud_front_private_key_filename
    File.join(Rails.root, 'config', 'certs', 'cloudfront.pem')
  end

  def self.cloud_front_private_key
    Rails.configuration.alonetone.amazon_cloud_front_private_key.presence ||
      File.read(cloud_front_private_key_filename)
  end

  def self.cloud_front_signer
    Aws::CloudFront::UrlSigner.new(
      key_pair_id: Rails.configuration.alonetone.amazon_cloud_front_key_pair_id,
      private_key: cloud_front_private_key
    )
  end

  def self.cloudfront_url(public_cloud_front_url)
    Listens.cloud_front_signer.signed_url(
      public_cloud_front_url,
      expires: 20.minutes.from_now
    )
  end

  private

  def listen(asset, register: true)
    unless prevent_abuse(asset)
      register_listen(asset) if register
      if Rails.application.play_dummy_audio?
        play_local_mp3
      elsif Rails.application.cloudfront_enabled?
        redirect_to Listens.cloudfront_url(asset.mp3.url)
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
