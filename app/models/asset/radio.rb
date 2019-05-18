# frozen_string_literal: true

class Asset < ApplicationRecord
  module Radio
    extend ActiveSupport::Concern

    DEFAULT_LIMIT = 20

    module ClassMethods
      def radio(channel, user)
        case channel
        when 'favorites'
            published.favorited

        when 'your_favorite_alonetoners'
            published.from_favorite_artists_of(user)

        when 'mangoz_shuffle'
            published.mangoz(user)

        when 'most_favorited'
            published.order('favorites_count DESC')

        when 'songs_you_have_not_heard'
            published.not_heard_by(user)

        when 'popular'
            published.order('hotness DESC')

        when 'those_you_follow'
            published.recent.new_tracks_from_followees(user)

        when 'spam'
            recent.where(is_spam: true)
        else # latest
            published.recent
        end
      end

      # random radio, without playing the same track twice in a 24 hour period
      def mangoz(user)
        ids = user&.listened_more_than?(10) && user&.listened_to_today_ids
        random_order.id_not_in(ids)
      end

      # random radio, sourcing from the user's favorite artists
      def from_favorite_artists_of(user)
          id_not_in(user.listened_to_today_ids)
            .user_id_in(user.most_listened_to_user_ids(10))
            .random_order
      end

      # finds all tracks not heard by the logged in user (or just the latest tracks for guests)
      def not_heard_by(user)
        random_order.id_not_in(user.listened_to_ids)
      end

      def new_tracks_from_followees(user, limit = Asset::Radio::DEFAULT_LIMIT)
        recent.user_id_in(user.follows_user_ids).limit(limit)
      end
    end
  end
end
