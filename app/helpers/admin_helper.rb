module AdminHelper
  NAV_GROUPS = [
    { items: [
      { label: "Dashboard", path_helper: :admin_path, icon: :home, controllers: %w[admin/dashboard] }
    ] },
    { label: "Onboarding", items: [
      { label: "Account Requests", path_helper: :admin_account_requests_path, icon: :inbox, controllers: %w[admin/account_requests] },
      { label: "Mass Invites", path_helper: :admin_mass_invites_path, icon: :ticket, controllers: %w[admin/mass_invites] }
    ] },
    { label: "Moderation", items: [
      { label: "Users", path_helper: :admin_users_path, icon: :users, controllers: %w[admin/users] },
      { label: "Tracks", path_helper: :admin_assets_path, icon: :music, controllers: %w[admin/assets] },
      { label: "Comments", path_helper: :admin_comments_path, icon: :chat, controllers: %w[admin/comments] },
      { label: "Listens", path_helper: :admin_listens_path, icon: :signal, controllers: %w[admin/listens] }
    ] },
    { items: [
      { label: "Devops", path_helper: :admin_devops_path, icon: :wrench, controllers: %w[admin/devops] }
    ] }
  ].freeze

  def admin_nav_groups
    NAV_GROUPS
  end

  def admin_nav_current?(item)
    item[:controllers].include?(controller_path)
  end

  def admin_chart_options
    {
      colors: ["#eb7b0c"],
      points: false,
      library: {
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
          x: { grid: { display: false }, ticks: { color: "#a6abab", maxRotation: 0, autoSkipPadding: 16 } },
          y: { beginAtZero: true, grid: { color: "#353535" }, ticks: { color: "#a6abab", precision: 0 } }
        }
      }
    }
  end

  STATUS_BADGE_STYLES = {
    "waiting" => "bg-warning/15 text-warning",
    "approved" => "bg-success/20 text-success-hover",
    "claimed" => "bg-success/20 text-success-hover",
    "denied" => "bg-danger/15 text-danger-hover"
  }.freeze

  ADMIN_BTN = {
    neutral: "rounded-lg border border-border bg-surface-overlay px-3 py-1.5 text-sm font-medium text-fg-muted hover:text-fg",
    success: "rounded-lg bg-success px-3 py-1.5 text-sm font-semibold text-white hover:brightness-90",
    danger: "rounded-lg bg-danger px-3 py-1.5 text-sm font-semibold text-white hover:brightness-90"
  }.freeze

  def admin_btn(kind) = ADMIN_BTN.fetch(kind)

  def admin_user_view_tabs(current)
    [
      { label: 'List', url: admin_users_path, active: current == :list },
      { label: 'Shared IPs', url: admin_shared_ips_path, active: current == :shared_ips },
      { label: 'Bandwidth', url: admin_bandwidth_path, active: current == :bandwidth }
    ]
  end

  def admin_listen_view_tabs(current)
    [
      { label: 'Listening IPs', url: admin_listens_path, active: current == :listening },
      { label: 'Banned IPs', url: admin_banned_ips_path, active: current == :banned }
    ]
  end

  def admin_track_view_tabs(current)
    [
      { label: 'List', url: admin_assets_path, active: current == :list },
      { label: 'Most Played', url: admin_most_played_path, active: current == :most_played },
      { label: 'All-Time', url: admin_all_time_path, active: current == :all_time }
    ]
  end

  def admin_status_badge(status)
    style = STATUS_BADGE_STYLES.fetch(status.to_s, "bg-surface-overlay text-fg-muted")
    content_tag :span, status.to_s.titleize,
      class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium #{style}"
  end

  def admin_icon(name, css: "size-5")
    svg = render(file: svg_path("svg/admin/#{name}.svg"))
    raw svg.sub("<svg", %(<svg class="#{css}"))
  end
end
