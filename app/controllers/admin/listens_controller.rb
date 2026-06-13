module Admin
  class ListensController < Admin::BaseController
    before_action :admin_only, only: %i[ban unban purge_listens]

    def index
      @admin_title = 'Listening IPs'
      @admin_range_enabled = true
      @ip_counts = Listen.top_ips(range: admin_range)
      @ban_matcher = BannedIp::Matcher.new(BannedIp.pluck(:ip))
    end

    def banned_ips
      @admin_title = 'Banned IPs'
      @banned_ips = BannedIp.includes(:banned_by).recent
    end

    def ban
      ip = params[:ip].to_s.strip
      banned = BannedIp.find_or_create_by(ip: ip) { |b| b.banned_by = current_user }
      if banned.persisted?
        flash[:ok] = "Banned #{ip}. You can purge its listen history from the Banned tab."
      else
        flash[:alert] = "Couldn't ban that IP: #{banned.errors.full_messages.to_sentence}"
      end
      redirect_to admin_listens_path, status: :see_other
    end

    def unban
      BannedIp.find(params[:id]).destroy
      flash[:ok] = 'IP unbanned.'
      redirect_to admin_banned_ips_path, status: :see_other
    end

    def purge_listens
      banned = BannedIp.find(params[:id])
      if banned.purgeable_listens?
        PurgeListensByIpJob.perform_later(banned.ip)
        flash[:ok] = "Purging all listens from #{banned.ip}..."
      else
        flash[:alert] = 'Purging is supported for exact IPs and IPv4 ranges only.'
      end
      redirect_to admin_banned_ips_path, status: :see_other
    end
  end
end
