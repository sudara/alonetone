module Admin
  class DashboardStats
    def initialize(range:, bucket:, range_key:)
      @range = range
      @bucket = bucket
      @range_key = range_key
    end

    def new_users = scoped(User).count
    def new_tracks = scoped(Asset).count
    def new_comments = scoped(Comment).where(is_spam: false).count
    def new_spam_comments = scoped(Comment).where(is_spam: true).count
    def total_users = User.count
    def total_tracks = Asset.count
    def total_comments = Comment.where(is_spam: false).count
    def total_listens = Asset.with_deleted.sum(:listens_count)

    # All-time uses the cached counter to avoid COUNT(*) over the multi-million-row listens table.
    def listens
      @range ? Listen.where(created_at: @range).count : total_listens
    end

    def new_users_series = series(User)
    def new_tracks_series = series(Asset)
    def new_comments_series = series(Comment.where(is_spam: false), cache_name: 'Comment/non_spam')

    # Bounded ranges only — an all-time GROUP BY would filesort the entire listens table.
    def listens_series
      series(Listen) if @range
    end

    # users.comments_count counts comments *received*, so commenters group even all-time.
    def top_commenters = top_users(Comment, :commenter_id)
    def top_uploaders = @range ? top_users(Asset, :user_id) : top_uploaders_all_time

    def waiting_account_requests = AccountRequest.waiting.count
    def spam_users = User.with_deleted.where(is_spam: true).count
    def spam_tracks = Asset.with_deleted.where(is_spam: true).count
    def spam_comments = Comment.where(is_spam: true).count
    def perma_deletable = User.destroyable.count + Asset.destroyable.count + Comment.destroyable.count

    private

    def scoped(model)
      @range ? model.where(created_at: @range) : model
    end

    # GROUP BY filesorts like the series do, so top lists share the short cache.
    def top_users(model, column)
      counts = Rails.cache.fetch("admin/dashboard-top/#{model.name}/#{@range_key}", expires_in: 10.minutes) do
        scoped(model).where(is_spam: false).where.not(column => nil)
          .group(column).order(Arel.sql('COUNT(*) DESC'), column).limit(5).count
      end
      to_user_rows(counts)
    end

    def top_uploaders_all_time
      counts = Rails.cache.fetch("admin/dashboard-top/Asset/#{@range_key}", expires_in: 10.minutes) do
        User.where(is_spam: false, assets_count: 1..)
          .order(assets_count: :desc, id: :asc).limit(5).pluck(:id, :assets_count).to_h
      end
      to_user_rows(counts)
    end

    # Soft-deleted users drop out here, so a card can show fewer than 5 rows.
    def to_user_rows(counts)
      users = User.where(id: counts.keys).index_by(&:id)
      counts.filter_map { |id, count| [users[id], count] if users[id] }
    end

    # Grouping by a date function always filesorts, so series are served from a short cache.
    def series(scope, cache_name: nil)
      cache_name ||= scope.name
      Rails.cache.fetch("admin/dashboard-series/#{cache_name}/#{@range_key}", expires_in: 10.minutes) do
        scope.public_send("group_by_#{@bucket}", :created_at, range: @range).count
      end
    end
  end
end
