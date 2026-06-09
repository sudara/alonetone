module Admin
  class DashboardStats
    def initialize(range:, bucket:, range_key:)
      @range = range
      @bucket = bucket
      @range_key = range_key
    end

    def new_users = scoped(User).count
    def new_tracks = scoped(Asset).count
    def new_comments = scoped(Comment).count

    # All-time uses the cached counter to avoid COUNT(*) over the multi-million-row listens table.
    def listens
      @range ? Listen.where(created_at: @range).count : Asset.with_deleted.sum(:listens_count)
    end

    def new_users_series = series(User)
    def new_tracks_series = series(Asset)
    def new_comments_series = series(Comment)

    # Bounded ranges only — an all-time GROUP BY would filesort the entire listens table.
    def listens_series
      series(Listen) if @range
    end

    def waiting_account_requests = AccountRequest.waiting.count
    def spam_users = User.with_deleted.where(is_spam: true).count
    def spam_tracks = Asset.with_deleted.where(is_spam: true).count
    def spam_comments = Comment.where(is_spam: true).count
    def perma_deletable = User.destroyable.count + Asset.destroyable.count

    private

    def scoped(model)
      @range ? model.where(created_at: @range) : model
    end

    # Grouping by a date function always filesorts, so series are served from a short cache.
    def series(model)
      Rails.cache.fetch("admin/dashboard-series/#{model.name}/#{@range_key}", expires_in: 10.minutes) do
        model.public_send("group_by_#{@bucket}", :created_at, range: @range).count
      end
    end
  end
end
