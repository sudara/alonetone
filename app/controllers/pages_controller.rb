class PagesController < ApplicationController
  layout 'pages', only: %i[about faq help why privacy]

  def twentyfour
    render layout: '24houralbum'
  end

  def rpm_challenge
    set_2009_albums
    set_2010_albums
    render layout: 'rpm_challenge'
  end

  def about
    @page_title = "About alonetone"
  end

  def help
    @page_title = "Help!"
  end

  def privacy
    @page_title = "Privacy Policy"
  end

  def faq
    @page_title = "Frequently Asked Questions"
  end

  def why
    @page_title = "Why I Built alonetone"
  end

  def home; end

  def error
    raise("A Purposeful Error Occurred")
  end

  def four_oh_four
    @page_title = "404 Not found"
    render layout: 'application', status: 404
  end

  def help_an_app_support_brutha_out
    query      = "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
    version    = ActiveRecord::Base.connection.select_value(query)
    time       = Time.now.to_formatted_s(:rfc822)
    render(text: "O Hai. You can haz alonetone. kthxbai!")
  end

  def press; end

  def stats
    @page_title = "Listening and Song Statistics"
    @number_of_musicians = User.musicians.count
    @comments_per_user = User.average('comments_count').try(:ceil) || 0
    @average_length_of_track = Asset.formatted_time(Asset.average('length').try(:ceil) || 0)
    @listens_per_track = Asset.average('listens_count').try(:ceil) || 0
    @listens_per_user = User.average('listens_count').try(:ceil) || 0
    @tracks_per_user = User.average('assets_count').try(:ceil) || 0
    @listens_per_week_per_track = Asset.average('listens_per_week').try(:ceil) || 0
  end

  def itunes
    @page_title = "How to get your music on iTunes (as a music podcast) with alonetone"
  end

  def ok
    ActiveRecord::Base.connection.execute("SELECT 1")
    ok = "OK"
    ok += '_QUEUE_UNDER_200' if Sidekiq::Stats.new.enqueued < 200
    ok += '_AND_WORKERS_UP' unless Sidekiq::ProcessSet.new.size > 0
    render plain: ok
  end

  def sitemap
    respond_to do |wants|
      wants.xml
    end
  end

  def toggle_theme
    respond_to :js
    if logged_in?
      current_user.toggle! :dark_theme
      session[:theme] = current_user.dark_theme? ? 'dark' : 'light'
    else
      session[:theme] = 'dark' if session[:theme] == 'light'
      session[:theme] ||= 'light'
    end
  end

  protected

  def set_2009_albums
    ids_2009 = [986, 951, 945, 924, 912, 915, 916, 918, 921, 923,
            926, 927, 928, 933, 935, 944, 910,
            906, 904, 899, 893, 892, 891, 887, 886, 882, 880,
            879, 877, 875, 872, 864, 863, 860, 858, 857, 856,
            855, 852, 849, 846, 845, 843, 842, 841,
            840, 838, 836, 834, 832, 831, 829, 828, 827,
            826, 825, 824, 823, 822, 821, 818, 817, 816, 814,
            812, 810, 806, 805, 804, 802, 801, 800, 716, 799, 798,
            797, 787, 786, 767, 762,
            760, 753, 745, 742, 739, 724, 729, 809, 819, 830]
    @albums_2009 = Playlist.where(id: ids_2009).order('created_at ASC').with_preloads
  end

  def set_2010_albums
    ids_2010 = [2140, 2037, 2151, 2096, 2152, 2082, 2158, 2157, 2107,
                2045, 2161, 2163, 2160, 2127, 2162, 2021, 2139, 2147,
                2141, 2164, 2167, 2046, 2084, 2153, 2173, 2172, 2007,
                2138, 2175, 2125, 2148, 2180, 2044, 2129, 2184, 2165,
                2078, 2108, 2029, 2195, 2083, 2194, 2187, 2182, 2196,
                2174, 2197, 2200, 2202, 2150, 2209, 2012, 2215, 2245,
                2241, 2234]
    @albums_2010 = Playlist.where(id: ids_2010).with_preloads
  end
end
