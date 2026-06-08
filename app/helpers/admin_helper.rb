module AdminHelper
  NavItem = Struct.new(:label, :path_helper, :icon, :controllers, keyword_init: true)

  NAV_GROUPS = [
    { label: nil, items: [
      NavItem.new(label: "Dashboard", path_helper: :admin_path, icon: :home, controllers: %w[admin])
    ] },
    { label: "Onboarding", items: [
      NavItem.new(label: "Account Requests", path_helper: :admin_account_requests_path, icon: :inbox, controllers: %w[admin/account_requests]),
      NavItem.new(label: "Mass Invites", path_helper: :admin_mass_invites_path, icon: :ticket, controllers: %w[admin/mass_invites])
    ] },
    { label: "Moderation", items: [
      NavItem.new(label: "Users", path_helper: :admin_users_path, icon: :users, controllers: %w[admin/users]),
      NavItem.new(label: "Tracks", path_helper: :admin_assets_path, icon: :music, controllers: %w[admin/assets]),
      NavItem.new(label: "Comments", path_helper: :admin_comments_path, icon: :chat, controllers: %w[admin/comments]),
      NavItem.new(label: "Listens", path_helper: :admin_listens_path, icon: :signal, controllers: %w[admin/listens])
    ] },
    { label: nil, items: [
      NavItem.new(label: "Devops", path_helper: :admin_devops_path, icon: :wrench, controllers: %w[admin/devops])
    ] }
  ].freeze

  def admin_nav_groups
    NAV_GROUPS
  end

  def admin_nav_current?(item)
    item.controllers.include?(controller_path)
  end

  # rubocop:disable Layout/LineLength -- opaque Heroicons path data, not meant to wrap
  ICON_PATHS = {
    home: "m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25",
    inbox: "M2.25 13.5h3.86a2.25 2.25 0 0 1 2.012 1.244l.256.512a2.25 2.25 0 0 0 2.013 1.244h3.218a2.25 2.25 0 0 0 2.013-1.244l.256-.512a2.25 2.25 0 0 1 2.012-1.244h3.86m-19.5.338V18a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 0 0-2.15-1.588H6.911a2.25 2.25 0 0 0-2.15 1.588L2.35 13.177a2.25 2.25 0 0 0-.1.661Z",
    ticket: "M16.5 6v.75m0 3v.75m0 3v.75m0 3V18m-9-5.25h5.25M7.5 15h3M3.375 5.25c-.621 0-1.125.504-1.125 1.125v3.026a2.999 2.999 0 0 1 0 5.198v3.026c0 .621.504 1.125 1.125 1.125h17.25c.621 0 1.125-.504 1.125-1.125v-3.026a2.999 2.999 0 0 1 0-5.198V6.375c0-.621-.504-1.125-1.125-1.125H3.375Z",
    users: "M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z",
    music: "M9 9l10.5-3m0 6.553v3.75a2.25 2.25 0 0 1-1.632 2.163l-1.32.377a1.803 1.803 0 1 1-.99-3.467l2.31-.66a2.25 2.25 0 0 0 1.632-2.163Zm0 0V2.25L9 5.25v10.303m0 0v3.75a2.25 2.25 0 0 1-1.632 2.163l-1.32.377a1.803 1.803 0 0 1-.99-3.467l2.31-.66A2.25 2.25 0 0 0 9 15.553Z",
    chat: "M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.847 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 0 1-.825-.242m9.345-8.334a2.126 2.126 0 0 0-.476-.095 48.64 48.64 0 0 0-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0 0 11.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155",
    signal: "M9.348 14.652a3.75 3.75 0 0 1 0-5.304m5.304 0a3.75 3.75 0 0 1 0 5.304m-7.425 2.121a6.75 6.75 0 0 1 0-9.546m9.546 0a6.75 6.75 0 0 1 0 9.546M5.106 18.894c-3.808-3.807-3.808-9.98 0-13.788m13.788 0c3.808 3.807 3.808 9.98 0 13.788M12 12h.008v.008H12V12Zm.375 0a.375.375 0 1 1-.75 0 .375.375 0 0 1 .75 0Z",
    wrench: "M11.42 15.17 17.25 21A2.652 2.652 0 0 0 21 17.25l-5.877-5.877M11.42 15.17l2.496-3.03c.317-.384.74-.626 1.208-.766M11.42 15.17l-4.655 5.653a2.548 2.548 0 1 1-3.586-3.586l6.837-5.63m5.108-.233c.55-.164 1.163-.188 1.743-.14a4.5 4.5 0 0 0 4.486-6.336l-3.276 3.277a3.004 3.004 0 0 1-2.25-2.25l3.276-3.276a4.5 4.5 0 0 0-6.336 4.486c.091 1.076-.071 2.264-.904 2.95l-.102.085m-1.745 1.437L5.909 7.5H4.5L2.25 3.75l1.5-1.5L7.5 4.5v1.409l4.26 4.26",
    menu: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5",
    close: "M6 18 18 6M6 6l12 12"
  }.freeze
  # rubocop:enable Layout/LineLength

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

  def admin_icon(name, css: "size-5")
    path = ICON_PATHS.fetch(name)
    content_tag(:svg, content_tag(:path, nil, "stroke-linecap": "round", "stroke-linejoin": "round", d: path),
      class: css, fill: "none", viewBox: "0 0 24 24", "stroke-width": "1.5", stroke: "currentColor", "aria-hidden": "true")
  end
end
