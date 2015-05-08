module Listens
  extend ActiveSupport::Concern
  include PreventAbuse

  # user agent whitelist
  # cfnetwork = Safari on osx 10.4 *only* when it tries to download
  @@valid_listeners = ['msie','webkit','quicktime','gecko','mozilla','netscape','itunes','chrome','opera', 'safari','cfnetwork','facebookexternalhit','ipad','iphone','apple','facebook']
 
  # user agent black list
  @@bots = ['bot','spider','baidu','mp3bot'] 

  def listen(asset)
    unless prevent_abuse(asset)
      register_listen(asset)
      if Alonetone.try(:play_dummy_mp3s)
        play_local_mp3
      else
        redirect_to asset.mp3.expiring_url.gsub('s3.amazonaws.com/','')
      end
    end
  end

  def user_agent
    request.user_agent.try(:downcase)    
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
      render(:text => "Denied due to abuse", :status => 403)    
    end
  end

  def register_listen(asset)
    asset.listens.create(
        :listener     => current_user || nil, 
        :track_owner  => asset.user, 
        :source       => listen_referer,
        :user_agent   => user_agent,
        :ip           => request.remote_ip
      ) unless is_a_bot? or ip_just_registered_this_listen?(asset)
  end
  
  def ip_just_registered_this_listen?(asset)
    last_listen = asset.listens.since(1.week.ago).where(:ip => request.remote_ip).first
    last_listen.present? && (last_listen.created_at > (Time.now - asset[:length]))
  end
  
  def is_a_bot?
    # gotta have a user agent
    return true unless request.user_agent.present?
    
    # can't be a blacklisted ip
    return true if is_from_a_bad_ip?
    
    # check user agent agaisnt both white and black lists
    not browser? or @@bots.any?{ |bot_agent| user_agent.include? bot_agent }  
  end
  
  def browser?
    @@valid_listeners.any?{ |valid_agent| user_agent.include? valid_agent } 
  end

  def play_local_mp3
    file_to_send = File.join(Rails.root,'spec/fixtures/assets/muppets.mp3')
    
    length = File.size(file_to_send) # need to do this manually for header to be set correctly

    # SHITTON OF HEADER HACKS TO APPEASE HTML5 locally :)
    file_begin = 0
    file_end = length - 1
    headers['Accept-Ranges'] = 'bytes'
    headers["Cache-Control"] = "public, must-revalidate, max-age=0"
    headers["Pragma"] = "no-cache"
    headers['Connection'] = 'close'
    if !request.headers["Range"] or request.headers["Range"]=="bytes=0-"# browser wants the whole file
      status = "200 OK"
      headers["Content-Length"] = (file_end.to_i - file_begin.to_i + 1).to_s

      send_file file_to_send, :type => 'audio/mpeg', :disposition => 'attachment;', 
      :url_based_filename => true, :status => status, :stream => true, :buffer_size  =>  4096
    else 
      status = "206 Partial Content" #browser wants part of the file
      match = request.headers['Range'].match(/bytes=(\d+)-(\d*)/)
      if match
        file_begin = match[1]
        file_end = match[2] if match[2] && !match[2].empty?
      end
      headers["Content-Range"] = "bytes " + file_begin.to_s + "-" + file_end.to_s + "/" + length.to_s
      headers["Content-Length"] = (file_end.to_i - file_begin.to_i + 1).to_s
      how_many_bytes = file_end.to_i-file_begin.to_i > 0 ? file_end.to_i-file_begin.to_i : 1
      send_data File.read(file_to_send,how_many_bytes,file_begin.to_i), :type =>'audio/mpeg', :disposition => 'attachment;', 
      :url_based_filename => true, :status => status, :stream => true, :buffer_size  =>  4096
    end
  end
end
