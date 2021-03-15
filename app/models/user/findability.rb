# frozen_string_literal: true

class User < ApplicationRecord
  module Findability
    extend ActiveSupport::Concern

    module ClassMethods
      def currently_online
         User.where(["last_request_at > ?", Time.now.utc - 15.minutes])
      end

      def conditions_by_like(value)
        conditions = ['users.display_name', 'users.login', 'profiles.bio', 'profiles.city', 'profiles.country'].collect do |c|
          "#{c} LIKE " + ActiveRecord::Base.connection.quote("%#{value}%")
        end
        where(conditions.join(" OR "))
      end

      def search(query, options = {})
        with_scope find: { conditions: build_search_conditions(query) } do
          find :all, options
        end
      end

      def build_search_conditions(query)
        query && ['LOWER(display_name) LIKE :q OR LOWER(login) LIKE :q', { q: "%#{query}%" }]
      end

      # feeds the users/index subnav
      def paginate_by_params(params)
        available_sortings = %w[last_uploaded patrons most_listened_to new_artists monster_uploaders dedicated_listeners]
        params[:sort] = 'last_seen' if !params[:sort].present? || !available_sortings.include?(params[:sort])
        send(params[:sort])
      end

      protected

      # needed to map incoming params to scopes
      def last_seen
        recently_seen
      end

      def patrons
        joins(:patron).preload(:patron)
      end

      def recently_joined
        activated
      end

      def new_artists
        musicians.reorder('users.created_at DESC')
      end

      def most_listened_to
        left_joins(:track_plays).group('users.id')
          .order('COUNT(listens.id) DESC')
          .where('listens.created_at > ?', 1.month.ago)
      end

      def monster_uploaders
        musicians.reorder('users.assets_count DESC')
      end

      def last_uploaded
        joins(:assets).order('assets.created_at DESC').distinct
      end

      def dedicated_listeners
        left_joins(:listens).group('users.id')
        .order('COUNT(listens.id) DESC')
        .where('listens.created_at > ?', 1.month.ago)
      end
    end
  end
end
