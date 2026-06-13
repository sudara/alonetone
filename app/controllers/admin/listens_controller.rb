module Admin
  class ListensController < Admin::BaseController
    before_action :admin_only, only: %i[ban unban purge_listens]

    def index
      @admin_title = 'Listening IPs'
      @admin_range_enabled = true
      @ip_counts = Listen.top_ips(range: admin_range)
      @ban_matcher = BannedIp::Matcher.new(BannedIp.pluck(:ip))
      @users_by_ip = users_by_current_login_ip(@ip_counts.keys)
    end

    def banned_ips
      @admin_title = 'Banned IPs'
      @banned_ips = BannedIp.includes(:banned_by).recent
      @listen_counts_by_banned_ip = listen_counts_by_banned_ip(@banned_ips)
      @users_by_banned_ip = users_by_banned_ip(@banned_ips)
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

    private

    def users_by_current_login_ip(ips)
      ips = ips.compact_blank
      return {} if ips.empty?

      User.with_deleted.where(current_login_ip: ips).with_preloads.order(:id).group_by(&:current_login_ip)
    end

    def listen_counts_by_banned_ip(banned_ips)
      exact_bans = banned_ips.reject(&:range?)
      exact_counts = Listen.with_deleted.where(ip: exact_bans.map(&:ip)).group(:ip).count

      banned_ips.to_h do |banned|
        count = banned.range? ? listen_count_in_range(banned.ip) : exact_counts.fetch(banned.ip, 0)
        [banned.id, count]
      end
    end

    def users_by_banned_ip(banned_ips)
      exact_bans = banned_ips.reject(&:range?)
      exact_users = users_by_current_login_ip(exact_bans.map(&:ip))

      banned_ips.to_h do |banned|
        users = banned.range? ? users_with_login_ip_in_range(banned.ip) : exact_users.fetch(banned.ip, [])
        [banned.id, users]
      end
    end

    def listen_count_in_range(cidr)
      range = IPAddr.new(cidr)
      return 0 unless range.ipv4?

      listen_counts_in_prefixed_range(range).sum do |ip, count|
        ip_covered_by_range?(range, ip) ? count : 0
      end
    rescue IPAddr::InvalidAddressError
      0
    end

    def users_with_login_ip_in_range(cidr)
      range = IPAddr.new(cidr)
      return [] unless range.ipv4?

      users_in_prefixed_range(range).select do |user|
        ip_covered_by_range?(range, user.current_login_ip)
      end
    rescue IPAddr::InvalidAddressError
      []
    end

    def listen_counts_in_prefixed_range(range)
      scope = Listen.with_deleted.where.not(ip: nil)
      prefix = ipv4_prefix(range)
      scope = scope.where('ip LIKE ?', "#{prefix}.%") if prefix.present?
      scope.group(:ip).count
    end

    def users_in_prefixed_range(range)
      scope = User.with_deleted.where.not(current_login_ip: nil)
      prefix = ipv4_prefix(range)
      scope = scope.where('current_login_ip LIKE ?', "#{prefix}.%") if prefix.present?
      scope.with_preloads.order(:id)
    end

    def ipv4_prefix(range)
      range.to_s.split('.').first(range.prefix / 8).join('.')
    end

    def ip_covered_by_range?(range, ip)
      range.include?(ip)
    rescue IPAddr::InvalidAddressError, TypeError
      false
    end
  end
end
