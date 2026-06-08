module Admin
  class ListensController < BaseController
    layout 'admin'

    before_action :admin_only, only: %i[ban]

    def index
      @admin_title = 'Listening IPs'
      @admin_range_enabled = true
      scope = admin_range ? Listen.where(created_at: admin_range) : Listen
      @ip_counts = scope.where.not(ip: nil).group(:ip).order('count_all DESC').limit(25).count
      @banned_set = BannedIp.pluck(:ip).to_set
    end

    def banned_ips
      @admin_title = 'Banned IPs'
      @banned_ips = BannedIp.includes(:banned_by).recent
    end

    def ban
      ip = params[:ip].to_s.strip
      banned = BannedIp.find_or_create_by(ip: ip) { |b| b.banned_by = current_user }
      if banned.persisted?
        PurgeListensByIpJob.perform_later(ip)
        flash[:ok] = "Banned #{ip} and queued a purge of its listens."
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
  end
end
